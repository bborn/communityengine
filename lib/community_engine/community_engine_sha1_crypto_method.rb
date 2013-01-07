class CommunityEngineSha1CryptoMethod
  def self.encrypt(*tokens)
    tokens = tokens.flatten
    password = tokens.shift
    salt = tokens.shift
    Digest::SHA1.hexdigest(['', salt, password, ''].join('--'))
  end

  def self.matches?(crypted, *tokens)
    encrypt(*tokens) == crypted
  end
end
