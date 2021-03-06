require "dnssd"
require "timeout"

require "airplay/logger"
require "airplay/devices"

module Airplay
  # Public: Browser class to find Airplay-enabled devices in the network
  #
  class Browser
    NoDevicesFound = Class.new(StandardError)

    SEARCH = "_airplay._tcp."

    def initialize
      @logger = Airplay::Logger.new("airplay::browser")
    end

    # Public: Browses in the search of devices and adds them to the nodes
    #
    # Returns nothing or raises NoDevicesFound if there are no devices
    #
    def browse
      timeout(5) do
        DNSSD.browse!(SEARCH) do |node|
          resolve(node)
          break unless node.flags.more_coming?
        end
      end
    rescue Timeout::Error => e
      raise NoDevicesFound
    end

    # Public: Access to the node list
    #
    # Returns the Devices list object
    #
    def devices
      @_devices ||= Devices.new
    end

    private

    # Private: Resolves a node given a node and a resolver
    #
    # node - The given node
    # resolver - The DNSSD::Server that is resolving nodes
    #
    # Returns if there are more nodes coming
    #
    def node_resolver(node, resolved)
      info = Socket.getaddrinfo(resolved.target, nil, Socket::AF_INET)
      ip = info[0][2]

      airplay_device = Device.new(
        name:     node.name.gsub(/\u00a0/, ' '),
        address: "#{ip}:#{resolved.port}",
      )

      devices << airplay_device

      resolved.flags.more_coming?
    end

    # Private: Resolves the node information given a node
    #
    # node - The node from the DNSSD browsing
    #
    # Returns nothing
    #
    def resolve(node)
      resolver = DNSSD::Service.new
      resolver.resolve(node) do |resolved|
        break unless node_resolver(node, resolved)
      end
    end
  end
end
