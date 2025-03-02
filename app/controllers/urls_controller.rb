class UrlsController < ApplicationController
  # Display form for creating a new shortened URL
  def new
    @url = Url.new
  end

  # Create a new shortened URL
  def create
    @url = Url.new(url_params)
    
    if @url.save
      # Set the shortened path using the record ID
      @url.set_shortened_path
      redirect_to url_path(@url.shortened_path), notice: 'URL was successfully shortened!'
    else
      render :new, status: :unprocessable_entity
    end
  end

  # Show details of a shortened URL
  def show
    @url = Url.find_by_shortened_path(params[:id])
    
    if @url.nil?
      redirect_to root_path, alert: 'URL not found.'
    end
  end

  # Redirect to the original URL
  def redirect
    @url = Url.find_by_shortened_path(params[:shortened_path])
    
    if @url
      @url.increment_visits!
      redirect_to @url.original_url, allow_other_host: true
    else
      redirect_to root_path, alert: 'URL not found.'
    end
  end
  
  private
  
  def url_params
    params.require(:url).permit(:original_url)
  end
end
