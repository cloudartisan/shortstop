class UrlsController < ApplicationController
  before_action :set_url, only: [ :show, :stats ]
  before_action :authorize_stats!, only: [ :stats ]

  # Display form for creating a new shortened URL
  def new
    @url = Url.new
    @recent_urls = recent_urls
  end

  # Create a new shortened URL, reusing an existing one where we can
  def create
    @url = existing_url || Url.new(url_params)
    @url.user ||= current_user if user_signed_in?

    if @url.persisted? || @url.save
      remember_url(@url)
      redirect_to url_path(@url.shortened_path), notice: "URL was successfully shortened!"
    else
      @recent_urls = recent_urls
      render :new, status: :unprocessable_content
    end
  end

  # Show details of a shortened URL. The slug is unguessable, so possession of
  # it is what grants access - anonymous visitors need this to see their link.
  def show
  end

  # Redirect to the original URL
  def redirect
    url = Url.find_by_shortened_path(params[:shortened_path])

    if url
      Visit.record(url, request)
      redirect_to url.original_url, allow_other_host: true
    else
      redirect_to root_path, alert: "URL not found."
    end
  end

  # Show statistics for a URL
  def stats
    visits = @url.visits.to_a

    @daily_visits = daily_visit_series(@url.visits)
    @chart_labels = @daily_visits.map { |date, _| date.strftime("%b %d") }
    @chart_data = @daily_visits.map { |_, count| count }

    @total_visits = visits.size
    @last_visit_at = visits.map(&:created_at).max

    @browsers = tally(visits) { |visit| browser_name(visit.user_agent) }
    @referrers = tally(visits) { |visit| referer_domain(visit.referer) }
  end

  private

  def set_url
    @url = Url.find_by_shortened_path(params[:id])
    redirect_to root_path, alert: "URL not found." if @url.nil?
  end

  # Owned URLs are private to their owner. Anonymous URLs have no owner to
  # check against, so the unguessable slug is the only credential.
  def authorize_stats!
    return if @url.nil? || @url.user.nil?
    return if @url.user == current_user

    redirect_to root_path, alert: "You are not authorized to view these statistics."
  end

  def url_params
    params.require(:url).permit(:original_url)
  end

  # Reuse a URL the same owner already shortened. Anonymous submissions are
  # keyed on the session so one visitor's links never surface for another.
  def existing_url
    submitted = url_params[:original_url]
    return nil if submitted.blank?

    if user_signed_in?
      Url.for_user_and_url(current_user.id, submitted).resolvable.first
    else
      Url.resolvable.where(id: session_url_ids, user_id: nil, original_url: submitted).first
    end
  end

  # The homepage list is scoped to the viewer: their own URLs when signed in,
  # otherwise the ones created in this browser session. It used to show every
  # user's links to anonymous visitors.
  def recent_urls
    scope = user_signed_in? ? current_user.urls : Url.where(id: session_url_ids, user_id: nil)
    scope.resolvable.order(created_at: :desc).limit(5)
  end

  def session_url_ids
    session[:url_ids] ||= []
  end

  def remember_url(url)
    return if user_signed_in?

    session[:url_ids] = (session_url_ids + [ url.id ]).last(50)
  end

  # Visits per day across the last 30 days, including days with no visits so
  # the chart's x-axis stays evenly spaced.
  def daily_visit_series(visits)
    window = 29.days.ago.to_date..Date.current
    counts = visits.where(created_at: window.first.beginning_of_day..)
                   .group("DATE(created_at)")
                   .count
                   .transform_keys { |key| key.to_date }

    window.map { |date| [ date, counts.fetch(date, 0) ] }
  end

  # Counts by category, ordered most frequent first. Every visit lands in
  # exactly one bucket, so the view can take its percentage denominator from
  # the hash itself - the old code divided by visits_count, which excluded
  # nothing but drifted, so referrer percentages never summed to 100.
  def tally(visits)
    visits.group_by { |visit| yield(visit) }
          .transform_values(&:count)
          .sort_by { |_, count| -count }
          .to_h
  end

  # Extract browser name from user agent
  def browser_name(user_agent)
    return "Unknown" if user_agent.blank?

    case user_agent
    when /Edg/ then "Edge"
    when /Chrome/ then "Chrome"
    when /Firefox/ then "Firefox"
    when /Safari/ then "Safari"
    when /MSIE|Trident/ then "Internet Explorer"
    else "Other"
    end
  end

  # Extract domain from referrer URL. Schemes without a host (mailto:, about:)
  # parse fine but yield a nil host, which used to raise.
  def referer_domain(referer)
    return "Direct" if referer.blank?

    host = URI.parse(referer).host
    return "Direct" if host.blank?

    host.delete_prefix("www.")
  rescue URI::Error
    "Invalid URL"
  end
end
