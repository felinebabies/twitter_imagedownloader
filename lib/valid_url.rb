# coding: utf-8

def valid_url url, limit
  raise ArgumentError, 'HTTP redirect too deep' if limit <= 0
  response = Net::HTTP.get_response(URI.parse(url))
  case response
  when Net::HTTPSuccess
    url
  when Net::HTTPRedirection
    valid_url response['location'], limit - 1
  else
    raise ItemNotFound
  end
end
