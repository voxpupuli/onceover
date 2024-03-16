Puppet::Functions.create_function(:'deployments::generate') do
  dispatch :generate do
    param 'Hash', :data
    param 'String[1]', :secret
  end

  def generate(data, secret)
    require 'jwt'

    # Remove quotes to work around CDPE-3903
    actual_secret = secret.gsub(/"/, '')

    JWT.encode(data, actual_secret)
  end
end
