# config

ADDRESSES = [# addresses to watch
  { addr: "1a8LDh3qtCdMFAgRXzMrdvB8w1EG4h1Xi", name: "Marshal coins", value: 29_656.51737286 }, # BTC
  { addr: "1EiNgZmQsFN4rJLZJWt93quMEz3X82FJd2", name: "mkvd out coins", value: 0.00750938 },
  # delete this addresses, add your own interesting adresses
]

class Neat
  require 'net/http'
  require 'json'

  def self.get(url)
    resp = Net::HTTP.get_response URI.parse url
    resp.body
  end

  def self.getj(url)
    JSON.parse get(url)
  end
end

class Address

  attr_reader :address, :balance

  def initialize(address)
    @address = address
    @response = Neat.getj "http://blockchain.info/address/#{address}?format=json"
    @balance = @response["final_balance"].to_f * 10**-8
  end
end

class Watcher

  def initialize
    @success = true
  end

  def watch_all
    for addr in ADDRESSES
      watch addr
    end

    puts "All balances match" if @success
  end

  private

  def watch(address)
    addr = Address.new address[:addr]
    balance_changed = addr.balance.round(7) != address[:value].round(7)

    notify(addr, address[:value]) if balance_changed
  end

  def notify(addr, value)
    @success = false
    main_notification
    puts "Balance changed #{addr.address}:\n#{value} mismatch from #{addr.balance} saved in config (#{(addr.balance-value).round(7).abs} difference)"
  end

  def main_notification
    # `speak balance changed` # osx
    `paplay /usr/share/sounds/KDE-Im-Irc-Event.ogg` # debian
  end

end

while true
  watcher = Watcher.new
  watcher.watch_all

  sleep 30
end