class LiveEvent < ApplicationRecord
  belongs_to :campaign

  enum status: { scheduled: 0, live: 1, ended: 2, cancelled: 3 }

  validates :title, presence: true
  validates :embed_url, format: { with: /\Ahttps:\/\/(www\.)?(youtube\.com|youtu\.be|twitch\.tv|restream\.io|streamyard\.com)\//i, message: 'must be a valid HTTPS URL from YouTube, Twitch, Restream, or StreamYard' }, allow_blank: true
  validates :stream_platform, inclusion: { in: %w[youtube twitch restream streamyard custom], message: 'must be a supported platform' }, allow_blank: true

  scope :upcoming, -> { where(status: :scheduled).where('scheduled_at > ?', Time.current).order(:scheduled_at) }
  scope :recent, -> { order(created_at: :desc) }

  def go_live!
    update!(status: :live, started_at: Time.current)
  end

  def end_stream!
    update!(status: :ended, ended_at: Time.current)
  end

  def embed_html
    return '' if embed_url.blank?
    url = sanitize_embed_url
    %(<iframe src="#{ERB::Util.html_escape(url)}" allowfullscreen allow="autoplay; encrypted-media" style="border:none;"></iframe>)
  end

  private

  def sanitize_embed_url
    uri = URI.parse(embed_url)
    case uri.host&.gsub('www.', '')
    when 'youtube.com'
      # Convert watch URLs to embed
      if embed_url.include?('/watch')
        video_id = Rack::Utils.parse_query(uri.query.to_s)['v']
        "https://www.youtube.com/embed/#{video_id}"
      elsif embed_url.include?('/live/')
        embed_url.gsub('/live/', '/embed/')
      else
        embed_url
      end
    when 'youtu.be'
      "https://www.youtube.com/embed/#{uri.path[1..]}"
    else
      embed_url
    end
  rescue URI::InvalidURIError
    embed_url
  end
end
