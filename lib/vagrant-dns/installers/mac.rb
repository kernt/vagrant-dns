module VagrantDNS
  module Installers
    class Mac
      attr_accessor :dns_options

      def initialize(dns_options)
        self.dns_options = dns_options
      end

      def install!
        require 'fileutils'
        dns_options.each do |opts|
          port = VagrantDNS::Config.listen.first.last
          tld = opts[:tld]
          contents = <<-FILE
# this file is generated by vagrant-dns
nameserver 127.0.0.1
port #{port}
FILE
          FileUtils.mkdir_p("/etc/resolver")
          File.open(File.join("/etc/resolver", tld), "w") do |f|
            f << contents
          end
        end
      rescue Errno::EACCES => e
        warn "vagrant-dns needs superuser access to manipulate DNS settings"
        raise e
      end

      def uninstall!
        require 'fileutils'

        dns_options.each do |opts|
          tld = opts[:tld]
          FileUtils.rm(File.join("/etc/resolver", tld))
        end
      rescue Errno::EACCES => e
        warn "vagrant-dns needs superuser access to manipulate DNS settings"
        raise e
      end
    end
  end
end