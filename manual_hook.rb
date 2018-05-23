#!/usr/bin/env ruby

require 'resolv'

# Struct to store a challenge
Challenge = Struct.new(:domain, :acme_domain, :txt_challenge)


# Check if a challenge is resolved, returns true in that case
def resolved?(dns, challenge)
  valid = false
  dns.each_resource(challenge[:acme_domain], Resolv::DNS::Resource::IN::TXT) { |resp|
    resp.strings.each do |curr_resp|
      if curr_resp == challenge[:txt_challenge]
        puts "✔ #{challenge[:acme_domain]}: Found #{curr_resp}, a match."
        return true
      end
    end
    valid = true
    puts "✘ #{challenge[:acme_domain]}: Found TXT record, but didn't match expected value of #{challenge[:txt_challenge]}"    
  }
  if !valid
    puts "✘ #{challenge[:acme_domain]}: Found no TXT record"
  end
  return false
end

def setup_dns(challenges)
  # DNS Resolver
  dns = Resolv::DNS.new
  first_iteration = true
  until challenges.empty? # Until all challenges are resolved
    challenges.delete_if do |challenge| # Delete resolved challenges
      resolved?(dns, challenge)
    end

    if first_iteration
      challenges.each do |challenge|
        puts "Create TXT record for the domain: \'#{challenge[:acme_domain]}\'. TXT record:"
        puts "\'#{challenge[:txt_challenge]}\'"
        puts "Press enter when DNS has been updated..."
        $stdin.readline
      end
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
