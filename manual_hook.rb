#!/usr/bin/env ruby

require 'resolv'

# Struct to store a challenge
Challenge = Struct.new(:domain, :acme_domain, :txt_challenge)


# Check if a challenge is resolved, returns true in that case
def resolved?(dns, challenge)
  dns.each_resource(challenge[:acme_domain], Resolv::DNS::Resource::IN::TXT) { |resp|
    if resp.strings[0] == challenge[:txt_challenge]
      puts "Found #{resp.strings[0]}. match."
      return true
    else
      puts "Found TXT record with the attribute_value(#{challenge[:acme_domain]}), but value(#{resp.strings[0]}) didn't match expected value of #{txt_challenge}"
    end
  }
  puts "There is no TXT record matching attribute value of #{challenge[:acme_domain]}"
  return false
end

def setup_dns(challenges)
  # DNS Resolver
  dns = Resolv::DNS.new
  first_iteration = true
  until challenges.empty? # Until all challenges are resolved
    challenges.delete_if do |challenge| # Delete resolved challenges
      puts "Checking for TXT record for the domain: \'#{challenge[:acme_domain]}\'."
      resolved?(dns, challenge)
    end

    if first_iteration
      challenges.each do |challenge|
        puts "Create TXT record for the domain: \'#{challenge[:acme_domain]}\'. TXT record:"
        puts "\'#{challenge[:txt_challenge]}\'"
      end
      puts "Press enter when DNS has been updated..."
      $stdin.readline
      first_iteration = false
    else
      unless challenges.empty?
        puts "Waiting to retry..."
        sleep 30
      end
    end
  end
end

def delete_dns(challenges)
  puts "Challenge complete. Leave TXT record in place to allow easier future refreshes."
end

if __FILE__ == $0
  # puts "ARGV: #{ARGV.inspect}"
  hook_stage = ARGV.shift
  challenges = []
  while ARGV.length >= 3
    domain = ARGV.shift
    acme_domain = "_acme-challenge.#{domain}".sub(/\.\*\./, ".")
    ARGV.shift
    txt_challenge = ARGV.shift
    challenges.push Challenge.new(domain, acme_domain, txt_challenge)
  end

  # puts "hook_stage: #{hook_stage}"
  # puts "challenges: #{challenges.inspect}"

  if hook_stage == "deploy_challenge"
    setup_dns(challenges)
  elsif hook_stage == "clean_challenge"
    delete_dns(challenges)
  end

end
