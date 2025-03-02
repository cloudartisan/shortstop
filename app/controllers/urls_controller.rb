class UrlsController < ApplicationController
  # Display form for creating a new shortened URL
  def new
    @url = Url.new
    @recent_urls = Url.order(created_at: :desc).limit(5)
  end

  # Create a new shortened URL or reuse existing one
  def create
    # Check if the URL already exists in the database
    existing_url = Url.find_by(original_url: url_params[:original_url])
    
    if existing_url && existing_url.shortened_path.present?
      # Reuse the existing URL if it has a shortened path
      redirect_to url_path(existing_url.shortened_path), notice: 'URL was successfully shortened!'
    else
      if existing_url
        # Use the existing URL but ensure it has a shortened path
        @url = existing_url
      else
        # Create a new URL
        @url = Url.new(url_params)
        @url.save
      end
      
      # Set the shortened path if not already set
      if @url.shortened_path.blank?
        @url.set_shortened_path
      end
      
      if @url.persisted?
        redirect_to url_path(@url.shortened_path), notice: 'URL was successfully shortened!'
      else
        render :new, status: :unprocessable_entity
      end
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
