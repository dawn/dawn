module GitHelper
  def strip_sshkey(key)
    key.strip =~ /\A(\S+\s[0-9A-Za-z\/\+=]+)/ ? $1 : nil
  end
end
