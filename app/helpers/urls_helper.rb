module UrlsHelper
  # Generate the full short URL with the host
  def short_url(path)
    request.base_url + '/' + path
  end
  
  # Format large numbers with commas
  def format_number(number)
    number_with_delimiter(number)
  end
  
  # Create a QR code for the URL
  def qr_code_url(url, size = 200)
    "https://api.qrserver.com/v1/create-qr-code/?size=#{size}x#{size}&data=#{CGI.escape(url)}"
  end
end
