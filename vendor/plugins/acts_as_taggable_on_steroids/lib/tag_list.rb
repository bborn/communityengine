class TagList < Array
  cattr_accessor :delimiter
  self.delimiter = ','
  def initialize(*args)
    add(*args)
  end
  
  # Add tags to the tag_list. Duplicate or blank tags will be ignored.
  #
  #   tag_list.add("Fun", "Happy")
  # 
  # Use the <tt>:parse</tt> option to add an unparsed tag string.
  #
  #   tag_list.add("Fun, Happy", :parse => true)
  def add(*names)
    extract_and_apply_options!(names)
    concat(names)
    clean!
    self
  end
  
  # Remove specific tags from the tag_list.
  # 
  #   tag_list.remove("Sad", "Lonely")
  #
  # Like #add, the <tt>:parse</tt> option can be used to remove multiple tags in a string.
  # 
  #   tag_list.remove("Sad, Lonely", :parse => true)
  def remove(*names)
    extract_and_apply_options!(names)
    delete_if { |name| names.include?(name) }
    self
  end
  
  # Transform the tag_list into a tag string suitable for edting in a form.
  # The tags are joined with <tt>TagList.delimiter</tt> and quoted if necessary.
  #
  #   tag_list = TagList.new("Round", "Square,Cube")
  #   tag_list.to_s # 'Round, "Square,Cube"'
  def to_s
    clean!
    
    list = map do |name|
      if delimiter.is_a?(Regexp)
        name.match(delimiter) ? "\"#{name}\"" : name
      else
        name.include?(delimiter) ? "\"#{name}\"" : name
      end
    end
    
    list.join( delimiter.is_a?(Regexp) ? "#{delimiter.source.match(/[^\\\[\]\*\?\{\}\.\|]/)[0]} " : (delimiter.ends_with?(" ") ? delimiter : "#{delimiter} ") )
  end
  
 private
  # Remove whitespace, duplicates, and blanks.
  def clean!
    reject!(&:blank?)
    map!(&:strip)
    uniq!
  end
  
  def extract_and_apply_options!(args)
    options = args.last.is_a?(Hash) ? args.pop : {}
    options.assert_valid_keys :parse
    
    if options[:parse]
      args.map! { |a| self.class.from(a) }
    end
    
    args.flatten!
  end
  
  class << self
    # Returns a new TagList using the given tag string.
    # 
    #   tag_list = TagList.from("One , Two,  Three")
    #   tag_list # ["One", "Two", "Three"]
    def from(string)
      new.tap do |tag_list|
        string = string.to_s.gsub('.', '').dup
                
        [
        /\s*#{delimiter}\s*(['"])(.*?)\1\s*/, 
        /^\s*(['"])(.*?)\1\s*#{delimiter}?/
        ].each do |re|
          string.gsub!(re) { tag_list << $2; "" }
        end        
        
        tag_list.add(string.split(delimiter))
      end
    end
  end
end
