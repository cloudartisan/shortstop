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
      # Record the visit with request information
      Visit.record(@url, request)
      @url.increment_visits!
      redirect_to @url.original_url, allow_other_host: true
    else
      redirect_to root_path, alert: 'URL not found.'
    end
  end
  
  # Show statistics for a URL
  def stats
    @url = Url.find_by_shortened_path(params[:id])
    
    if @url
      # Get visits grouped by day for the chart
      @daily_visits = @url.visits
                          .group_by { |v| v.created_at.to_date }
                          .transform_values(&:count)
                          .sort_by { |date, _| date }
                          .last(30) # Last 30 days with data
      
      # Format for chart.js
      @chart_labels = @daily_visits.map { |date, _| date.strftime("%b %d") }
      @chart_data = @daily_visits.map { |_, count| count }
      
      # Get browser and platform stats
      @browsers = @url.visits
                      .group_by { |v| browser_name(v.user_agent) }
                      .transform_values(&:count)
                      .sort_by { |_, count| -count }
                      .to_h
      
      # Get referrer stats
      @referrers = @url.visits
                        .where.not(referer: nil)
                        .group_by { |v| referer_domain(v.referer) }
                        .transform_values(&:count)
                        .sort_by { |_, count| -count }
                        .to_h
    else
      redirect_to root_path, alert: 'URL not found.'
    end
  end
  
  private
  
  def url_params
    params.require(:url).permit(:original_url)
  end
  
  # Extract browser name from user agent
  def browser_name(user_agent)
    return "Unknown" if user_agent.blank?
    
    if user_agent.include?('Chrome') && !user_agent.include?('Edg')
      'Chrome'
    elsif user_agent.include?('Firefox')
      'Firefox'
    elsif user_agent.include?('Safari') && !user_agent.include?('Chrome')
      'Safari'
    elsif user_agent.include?('Edg')
      'Edge'
    elsif user_agent.include?('MSIE') || user_agent.include?('Trident')
      'Internet Explorer'
    else
      'Other'
    end
  end
  
  # Extract domain from referrer URL
  def referer_domain(referer)
    return "Direct" if referer.blank?
    
    begin
      uri = URI.parse(referer)
      host = uri.host
      host.start_with?('www.') ? host[4..-1] : host
    rescue URI::InvalidURIError
      "Invalid URL"
    end
  end
end
