#!/usr/bin/env ruby

require 'resolv'

def setup_dns(domain, txt_challenge)
  dns = Resolv::DNS.new;
  acme_domain = "_acme-challenge."+domain; 
  puts "Checking TXT record for the domain: \"#{acme_domain}\". TXT record:"
  puts "\"#{txt_challenge}\""
  resolved = false;

  until resolved
    dns.each_resource(acme_domain, Resolv::DNS::Resource::IN::TXT) { |resp|
     if resp.strings[0] == txt_challenge
       puts "Found #{resp.strings[0]}. match."
       resolved = true;
     else
       puts "Found #{resp.strings[0]}. no match."
     end
    }

    if !resolved

     puts "Create TXT record for the domain: \"#{acme_domain}\". TXT record:"
     puts "\"#{txt_challenge}\""
     puts "Press enter when DNS has been updated..."
     $stdin.readline()

     puts "Didn't find a match for #{txt_challenge}"; 
     puts "Waiting to retry..."; 
     sleep 30; 
    end
  end
end

def delete_dns(domain, txt_challenge)
  puts "Challenge complete. Leave TXT record in place to allow easier future refreshes."
end

if __FILE__ == $0
  hook_stage = ARGV[0]
  domain = ARGV[1]
  txt_challenge = ARGV[3]

  # puts hook_stage
  # puts domain
  # puts txt_challenge

  if hook_stage == "deploy_challenge"
    setup_dns(domain, txt_challenge)
  elsif hook_stage == "clean_challenge"
    delete_dns(domain, txt_challenge)
  end

end
