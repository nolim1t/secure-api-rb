#\ -s puma
require 'cgi'
require 'base64'
require 'digest/sha2'
require "openssl"

def encrypt(key, string)
  ssl_sign = OpenSSL::HMAC.digest('sha512', key, string)
  signed_response = Base64.encode64(ssl_sign).to_s.gsub("\n",'')
  # can also do a Digest::SHA2.hexdigest
  signed_response
end
app_secret_key = "some random key" || ENV['APP_SECRET_KEY']
run Proc.new { |env|
  req = Rack::Request.new(env)
  if env["QUERY_STRING"] != "" then
    params = req.GET()
  end
  if env["REQUEST_METHOD"] == "POST" then
    params = req.POST()
  end
  response =  [404, {'Content-Type' => 'text/plain'}, ["Invalid request"]]
  if req.path == "/hash" and req.POST() then
    if params then
      if params["string"] then
        if params["string"] != "" then
            encrypt_result = encrypt app_secret_key, params["string"]
            response =  [404, {'Content-Type' => 'text/plain'}, [encrypt_result]]
        end
      end
    end
  end
  response
}
