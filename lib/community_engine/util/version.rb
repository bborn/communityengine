module CommunityEngine
  def self.version
    File.read(File.expand_path("../../../../VERSION", __FILE__)).strip
  end
end
