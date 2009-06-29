# = S3 Rake - Use S3 as a backup repository for your SVN repository, code directory, and MySQL database
#
# Author::    Adam Greene
# Copyright:: (c) 2006 6 Bar 8, LLC., Sweetspot.dm
# License::   GNU
#
# Feedback appreciated: adam at [nospam] 6bar8 dt com
#
# = Synopsis
#
#  from the CommandLine within your RubyOnRails application folder
#  $ rake -T
#    rake s3:backup                      # Backup code, database, and scm to S3
#    rake s3:backup:code                 # Backup the code to S3
#    rake s3:backup:db                   # Backup the database to S3
#    rake s3:backup:scm                  # Backup the scm repository to S3
#    rake s3:manage:clean_up             # Remove all but the last 10 most recent backup archive or optionally specify KEEP=5 to keep
#                                            the last 5
#    rake s3:manage:delete_bucket        # delete bucket.  You need to pass in NAME=bucket_to_delete.  Set FORCE=true if you want to 
#                                        #   delete the bucket even if there are items in it.
#    rake s3:manage:list                 # list all your backup archives
#    rake s3:manage:list_buckets         # list all your S3 buckets
#    rake s3:retrieve                    # retrieve the latest revision of code, database, and scm from S3. 
#                                        #   If  you need to specify a specific version, call the individual retrieve tasks
#    rake s3:retrieve:code               # retrieve the latest code backup from S3, or optionally specify a VERSION=this_archive.tar.gz
#    rake s3:retrieve:db                 # retrieve the latest db backup from S3, or optionally specify a VERSION=this_archive.tar.gz
#    rake s3:retrieve:scm                # retrieve the latest scm backup from S3, or optionally specify a VERSION=this_archive.tar.gz
#
# = Description
#
#  There are a few prerequisites to get this up and running:
#    * please download the Amazon S3 ruby library and place it in your ./lib/ directory
#      http://developer.amazonwebservices.com/connect/entry.jspa?externalID=135&categoryID=47
#    * You will need a 's3.yml' file in ./config/.  Sure, you can hard-code the information in this rake task,
#      but I like the idea of keeping all your configuration information in one place.  The File will need to look like:
#        aws_access_key: ''
#        aws_secret_access_key: ''
#        options:
#            use_ssl: true #set it to true or false
#
#  Once these two requirements are met, you can easily integrate these rake tasks into capistrano tasks or into cron.
#    * For cron, put this into a file like .backup.cron.  You can drop this file into /etc/cron.daily,
#      and make sure you chmod +x .backup.cron.  Also make sure it is owned by the appropriate user (probably 'root'.):
#
#      #!/bin/sh
#
#      # change the paths as you need...
#      cd /var/www/apps//current/ && rake s3:backup >/dev/null 2>&1
#      cd /var/www/apps/staging./current/ && rake s3:backup >/dev/null 2>&1
#
#    * within your capistrano recipe file, you can add tasks like these:
#
#     task :before_migrate, :roles => [:app, :db, :web] do
#        # this will back up your svn repository, your code directory, and your mysql db.
#        run "cd #{current_path} && rake --trace RAILS_ENV=production s3:backup"
#     end
#
# = Future enhancements
#
#  * encrypt the files before they are sent to S3
#  * when doing a retrieve, uncompress and untar the files for the user.  
#  * any other enhancements? 
#
# = Credits and License
#
#  inspired by rshll, developed by Dominic Da Silva:
#    http://rubyforge.org/projects/rsh3ll/
#
# This library is licensed under the GNU General Public License (GPL)
#  [http://dev.perl.org/licenses/gpl1.html].
#
#  additions by Charles Brian Quinn at slingshothosting:
#    http://www.slingshothosting.com/
#   *  use of INCREMENT variable
#   *  database adapter independent (mysqldump or pg_dump)
#
#
require 'vendor/plugins/community_engine/lib/s3'
require 'yaml'
require 'erb'
require 'active_record'
namespace :s3 do

  desc "Backup code, database, and scm to S3"
  task :backup => [ "s3:backup:code",  "s3:backup:db", "s3:backup:scm"]

  namespace :backup do
    desc "Backup the code to S3"
    task :code  do
      msg "backing up CODE to S3"
      make_bucket('code')
      archive = "/tmp/#{archive_name('code')}"

      # copy it to tmp just to play it safe...
      cmd = "cp -rp #{Dir.pwd} #{archive}"
      msg "extracting code directory"
      puts cmd
      result = system(cmd)      
      raise("copy of code dir failed..  msg: #{$?}") unless result

      send_to_s3('code', archive)
    end #end code task

    desc "Backup the database to S3"
    task :db  do
      msg "backing up the DATABASE to S3"
      make_bucket('db')
      archive = "/tmp/#{archive_name('db')}"

      msg "retrieving db info"
      adapter, database, user, password = retrieve_db_info

      msg "dumping db"
      if adapter == "mysql"
        cmd = "mysqldump --opt --skip-add-locks --max-allowed-packet=600M -u #{user} "
      elsif adapter == "postgresql"
        cmd = "/usr/local/pgsql/bin/pg_dump -U #{user} "
      else
        raise("database dump failed.  msg: unknown adapter")
      end
      puts cmd + "... [password filtered]"
      cmd += " -p'#{password}' " unless password.nil?
      cmd += " #{database} > #{archive}"
      result = system(cmd)
      raise("database dump failed.  msg: #{$?}") unless result

      send_to_s3('db', archive)
    end

    desc "Backup the scm repository to S3"
    task :scm  do
      msg "backing up the SCM repository to S3"
      make_bucket('scm')
      archive = "/tmp/#{archive_name('scm')}"
      # archive = "/tmp/#{archive_name('scm')}.tar.gz"
      svn_info = {}
      IO.popen("svn info") do |f|
        f.each do |line|
          line.strip!
          next if line.empty?
          split = line.split(':')
          svn_info[split.shift.strip] = split.join(':').strip
        end
      end

      url_type, repo_path = svn_info['URL'].split('://')
      repo_path.gsub!(/\/+/, '/').strip!
      url_type.strip!

      use_svnadmin = true
      final_path = svn_info['URL']
      if url_type =~ /^file/
        puts "'#{svn_info['URL']} is local!"
        final_path = find_scm_dir(repo_path)
      else
        puts "'#{svn_info['URL']}' is not local!\nWe will see if we can find a local path."
        repo_path = repo_path[repo_path.index('/')...repo_path.size]
        repo_path = find_scm_dir(repo_path)
        if File.exists?(repo_path)
          uuid = File.read("#{repo_path}/db/uuid").strip!
          if uuid == svn_info['Repository UUID']
            puts "We have found the same SVN repo at: #{repo_path} with a matching UUID of '#{uuid}'"
            final_path = find_scm_dir(repo_path)
          else
            puts "We have not found the SVN repo at: #{repo_path}.  The uuid's are different."
            use_svnadmin = false
            final_path = svn_info['URL']
          end
        else
          puts "No SVN repository at #{repo_path}."
          use_svnadmin = false
          final_path = svn_info['URL']          
        end
      end

      #ok, now we need to do the work...
      cmd = use_svnadmin ? "svnadmin dump -q #{final_path} > #{archive}" : "svn co -q --ignore-externals --non-interactive #{final_path} #{archive}"
      msg "extracting svn repository"
      puts cmd
      result = system(cmd)
      raise "previous command failed.  msg: #{$?}" unless result
      send_to_s3('scm', archive)
    end #end scm task
  end # end backup namespace

  desc "retrieve the latest revision of code, database, and scm from S3.  If  you need to specify a specific version, call the individual retrieve tasks"
  task :retrieve => [ "s3:retrieve:code",  "s3:retrieve:db", "s3:retrieve:scm"]

  namespace :retrieve do
    desc "retrieve the latest code backup from S3, or optionally specify a VERSION=this_archive.tar.gz"
    task :code  do
      retrieve_file 'code', ENV['VERSION']
    end

    desc "retrieve the latest db backup from S3, or optionally specify a VERSION=this_archive.tar.gz"
    task :db  do
      retrieve_file 'db', ENV['VERSION']
    end

    desc "retrieve the latest scm backup from S3, or optionally specify a VERSION=this_archive.tar.gz"
    task :scm  do
      retrieve_file 'scm', ENV['VERSION']
    end
  end #end retrieve namespace

  namespace :manage do
    desc "Remove all but the last 10 most recent backup archive or optionally specify KEEP=5 to keep the last 5"
    task :clean_up  do
      keep_num = ENV['KEEP'] ? ENV['KEEP'].to_i : 10
      puts "keeping the last #{keep_num}"
      cleanup_bucket('code', keep_num)
      cleanup_bucket('db', keep_num)
      cleanup_bucket('scm', keep_num)
    end

    desc "list all your backup archives"
    task :list  do
      print_bucket 'code'
      print_bucket 'db'
      print_bucket 'scm'
    end

    desc "list all your S3 buckets"
    task :list_buckets do
      puts conn.list_all_my_buckets.entries.map { |bucket| bucket.name }
    end

    desc "delete bucket.  You need to pass in NAME=bucket_to_delete.  Set FORCE=true if you want to delete the bucket even if there are items in it."
    task :delete_bucket do
      name = ENV['NAME']
      raise "Specify a NAME=bucket that you want deleted" if name.blank?
      force = ENV['FORCE'] == 'true' ? true : false

      cleanup_bucket(name, 0, false) if force
      response = conn.delete_bucket(name).http_response.message
      response = "Yes" if response == 'No Content'
      puts "deleting bucket #{bucket_name(name)}.  Successful? #{response}"
    end
  end #end manage namespace
end


  private

  def find_scm_dir(path)
    #double check if the path is a real physical path vs a svn path
    final_path = path
    tmp_path = final_path
    len = tmp_path.split('/').size
    while !File.exists?(tmp_path) && len > 0 do
      len -= 1
      tmp_path = final_path.split('/')[0..len].join('/')
    end
    final_path = tmp_path if len > 1
    final_path
  end

  # will save the file from S3 in the pwd.
  def retrieve_file(name, specific_file)
    msg "retrieving a #{name} backup from S3"
    entries = conn.list_bucket(bucket_name(name)).entries
    raise "No #{name} backups to retrieve" if entries.size < 1

    entry = entries.find{|entry| entry.key == specific_file}
    raise "Could not find the file '#{specific_key}' in the #{name} bucket" if entry.nil? && !specific_file.nil?
    entry_key = specific_file.nil? ? entries.last.key : entry.key
    msg "retrieving archive: #{entry_key}"
    data =  conn.get(bucket_name(name), entry_key).object.data
    File.open(entry_key, "wb") { |f| f.write(data) }  
    msg "retrieved file './#{entry_key}'"
  end

  # print information about an item in a particular bucket
  def print_bucket(name)
    msg "#{bucket_name(name)} Bucket"
    conn.list_bucket(bucket_name(name)).entries.map do |entry| 
      puts "size: #{entry.size/1.megabyte}MB,  Name: #{entry.key},  Last Modified: #{Time.parse( entry.last_modified ).to_s(:short)} UTC"
    end
  end

  # go through and keep a certain number of items within a particular bucket, 
  # and remove everything else.
  def cleanup_bucket(name, keep_num, convert_name=true)
    msg "cleaning up the #{name} bucket"
    bucket = convert_name ? bucket_name(name) : name
    entries = conn.list_bucket(bucket).entries #will only retrieve the last 1000
    remove = entries.size-keep_num-1
    entries[0..remove].each do |entry|
      response = conn.delete(bucket, entry.key).http_response.message
      response = "Yes" if response == 'No Content'
      puts "deleting #{bucket}/#{entry.key}, #{Time.parse( entry.last_modified ).to_s(:short)} UTC.  Successful? #{response}"
    end unless remove < 0
  end

  # open a S3 connection 
  def conn
    @s3_configs ||= YAML::load(ERB.new(IO.read("#{RAILS_ROOT}/config/s3.yml")).result)
    @conn ||= S3::AWSAuthConnection.new(@s3_configs['aws_access_key'], @s3_configs['aws_secret_access_key'], @s3_configs['options']['use_ssl'])
  end

  # programatically figure out what to call the backup bucket and 
  # the archive files.  Is there another way to do this?
  def project_name
    # using Dir.pwd will return something like: 
    #   /var/www/apps/staging.sweetspot.dm/releases/20061006155448
    # instead of
    # /var/www/apps/staging.sweetspot.dm/current
    pwd = ENV['PWD'] || Dir.pwd
    #another hack..ugh.  If using standard capistrano setup, pwd will be the 'current' symlink.
    pwd = File.dirname(pwd) if File.symlink?(pwd)
    File.basename(pwd)
  end

  # create S3 bucket.  If it already exists, not a problem!
  def make_bucket(name)
    msg = conn.create_bucket(bucket_name(name)).http_response.message
    raise "Could not make bucket #{bucket_name(name)}.  Msg: #{msg}" if msg != 'OK'
    msg "using bucket: #{bucket_name(name)}"
  end

  def bucket_name(name)
    # it would be 'nicer' if could use '/' instead of '_' for bucket names...but for some reason S3 doesn't like that
    "#{token(name)}_backup"
  end

  def token(name)
    "#{project_name}_#{ENV['INCREMENT'] ? "#{ENV['INCREMENT']}_" : ""}#{name}"
  end

  def archive_name(name)
    @timestamp ||= Time.now.utc.strftime("%Y%m%d%H%M%S")
    token(name).sub('_', '.') + ".#{RAILS_ENV}.#{@timestamp}"
  end

  # put files in a zipped tar everything that goes to s3
  # send it to the appropriate backup bucket
  # then does a cleanup
  def send_to_s3(name, tmp_file)
    archive = "/tmp/#{archive_name(name)}.tar.gz"

    msg "archiving #{name}"
    cmd = "tar -cpzf #{archive} #{tmp_file}"
    puts cmd
    system cmd

    msg "sending archived #{name} to S3"
    # put file with default 'private' ACL
    bytes = nil
    File.open(archive, "rb") { |f| bytes = f.read }  
    #set the acl as private       
    headers =  { 'x-amz-acl' => 'private', 'Content-Length' =>  FileTest.size(archive).to_s }
    response =  conn.put(bucket_name(name), archive.split('/').last, bytes, headers).http_response.message
    msg "finished sending #{name} S3"

    msg "cleaning up"
    cmd = "rm -rf #{archive} #{tmp_file}"
    puts cmd
    system cmd  
  end

  def msg(text)
    puts " -- msg: #{text}"
  end

  def retrieve_db_info
    # read the remote database file....
    # there must be a better way to do this...
    result = File.read "#{RAILS_ROOT}/config/database.yml"
    result.strip!
    config_file = YAML::load(ERB.new(result).result)
    return [
      config_file[RAILS_ENV]['adapter'],
      config_file[RAILS_ENV]['database'],
      config_file[RAILS_ENV]['username'],
      config_file[RAILS_ENV]['password']
    ]
  end

