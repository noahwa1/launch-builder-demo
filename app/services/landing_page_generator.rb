class LandingPageGenerator
  TEMPLATES = {
    'standard'            => 'Standard',
    'personalized_video'  => 'Personalized Video',
    'preorder_incentive'  => 'Preorder Incentive',
    'address_capture'     => 'Address Capture',
    'landing_page'        => 'Landing Page',
    'vinyl'               => 'Vinyl / Music'
  }.freeze

  DEFAULT_RETAILERS = [
    { name: 'Amazon', url: 'https://amazon.com', icon: "\u{1F4E6}" },
    { name: 'Barnes & Noble', url: 'https://barnesandnoble.com', icon: "\u{1F4DA}" },
    { name: 'Bookshop.org', url: 'https://bookshop.org', icon: "\u{1F3EA}" },
    { name: 'Target', url: 'https://target.com', icon: "\u{1F3AF}" },
    { name: 'Walmart', url: 'https://walmart.com', icon: "\u{1F6D2}" },
    { name: 'Books-A-Million', url: 'https://booksamillion.com', icon: "\u{1F4D6}" }
  ].freeze

  DEFAULT_BONUSES = [
    { emoji: "\u{270D}\u{FE0F}", title: 'Signed Bookplate', description: 'A personal signed bookplate from the author' },
    { emoji: "\u{1F4D6}", title: 'Bonus Chapter', description: 'An exclusive bonus chapter not in the final book' },
    { emoji: "\u{1F381}", title: 'Limited Print', description: 'Exclusive art print (first 500 orders)' }
  ].freeze

  DEFAULT_TESTIMONIAL = [
    { quote: '"An absolutely captivating read from start to finish."', attribution: '- Reader Review' }
  ].freeze

  TEMPLATE_STEPS = {
    'personalized_video' => [
      { number: '1', title: 'Order the Book', description: 'Purchase from any retailer below' },
      { number: '2', title: 'Submit Your Receipt', description: 'Upload your proof of purchase' },
      { number: '3', title: 'Get Confirmed', description: "We'll verify your order" },
      { number: '4', title: 'Enjoy Your Video', description: 'Receive a personalized video message' }
    ],
    'preorder_incentive' => [
      { number: '1', title: 'Pre-Order the Book', description: 'Purchase from any retailer below' },
      { number: '2', title: 'Submit Your Receipt', description: 'Upload your proof of purchase' },
      { number: '3', title: 'Get Confirmed', description: "We'll verify your pre-order" },
      { number: '4', title: 'Enjoy Your Bonus', description: 'Receive your exclusive bonus content' }
    ]
  }.freeze

  TEMPLATE_CTA = {
    'standard'            => 'Order Your Copy',
    'personalized_video'  => 'Get Your Personalized Video',
    'preorder_incentive'  => 'Pre-Order Now',
    'address_capture'     => 'Claim Your Signed Copy',
    'landing_page'        => 'Learn More',
    'vinyl'               => 'Order Vinyl'
  }.freeze

  # Campaign mode:   LandingPageGenerator.new(campaign)
  # Standalone mode:  LandingPageGenerator.new(nil, author: author, book: book, company_name: "Acme", company_email: "hi@acme.com")
  # Wizard mode:      LandingPageGenerator.new(campaign, wizard_data: { template: 'standard', hero: { headline: '...' }, ... })
  def initialize(campaign, author: nil, book: nil, company_name: nil, company_email: nil, template: 'standard', wizard_data: nil)
    @campaign = campaign
    @company_name = company_name
    @company_email = company_email
    @wizard_data = wizard_data&.deep_symbolize_keys
    @template = if @wizard_data&.dig(:template)
                  t = @wizard_data[:template].to_s
                  TEMPLATES.key?(t) ? t : 'standard'
                else
                  TEMPLATES.key?(template.to_s) ? template.to_s : 'standard'
                end

    if @campaign
      @submission = campaign.submission
      @author = campaign.author
      @book = nil
    else
      @author = author
      @book = book
      @submission = nil
    end
  end

  def generate
    { html: build_html, css: build_css }
  end

  private

  # ── Wizard-aware data accessors ──

  def w(section, key, default)
    @wizard_data&.dig(section, key).presence || default
  end

  def book_title
    return w(:hero, :headline, nil) if @wizard_data&.dig(:hero, :headline).present?
    if @submission
      @submission.title || 'Your Book Title'
    elsif @book
      @book.title || 'Your Book Title'
    else
      'Your Book Title'
    end
  end

  def book_description
    return w(:book, :description, nil) if @wizard_data&.dig(:book, :description).present?
    if @submission
      @submission.description || 'A captivating book that will keep you turning pages.'
    elsif @book
      @book.description || 'A captivating book that will keep you turning pages.'
    else
      'A captivating book that will keep you turning pages.'
    end
  end

  def book_cover_html
    cover = @submission&.cover || @book&.cover
    if cover.present? && cover.url.present?
      %(<img src="#{cover.url}" alt="#{h book_title}" style="width:100%;box-shadow:0 4px 20px rgba(0,0,0,0.15);">)
    else
      %(<div style="width:100%;aspect-ratio:2/3;background:#e8e8e8;border-radius:4px;display:flex;align-items:center;justify-content:center;color:#999;font-size:14px;box-shadow:0 4px 20px rgba(0,0,0,0.15);">Book Cover</div>)
    end
  end

  def author_name
    return w(:author, :name, nil) if @wizard_data&.dig(:author, :name).present?
    @author&.full_name || 'Author Name'
  end

  def author_bio
    return w(:author, :bio, nil) if @wizard_data&.dig(:author, :bio).present?
    @author&.description || 'About the author.'
  end

  def author_image_html
    if @author&.image.present?
      %(<img src="#{h @author.image}" alt="#{h author_name}" style="width:100%;">)
    else
      %(<div style="width:100%;min-height:350px;background:#e0e0e0;border-radius:4px;display:flex;align-items:center;justify-content:center;color:#999;font-size:14px;">Author Photo</div>)
    end
  end

  def genre
    return w(:book, :genre, nil) if @wizard_data&.dig(:book, :genre).present?
    @submission&.genre || 'General'
  end

  def release_date
    return w(:book, :release_date, nil) if @wizard_data&.dig(:book, :release_date).present?
    date = @submission&.release_date || @book&.release_date
    date&.strftime('%B %d, %Y') || 'Coming Soon'
  end

  def hero_subheadline
    w(:hero, :subheadline, "by #{author_name}")
  end

  def hero_cta_text
    w(:hero, :cta_text, TEMPLATE_CTA[@template] || 'Order Your Copy')
  end

  def hero_cta_url
    w(:hero, :cta_url, purchase_url)
  end

  def purchase_url
    @campaign&.signed_editions_url.presence || '#'
  end

  def company_bar_html
    return '' unless @company_name.present?
    email_html = @company_email.present? ? %( — <a href="mailto:#{h @company_email}" style="color:#C5A44E;">#{h @company_email}</a>) : ''
    %(<div class="company-bar"><div class="container">Offered by <strong>#{h @company_name}</strong>#{email_html}</div></div>)
  end

  def h(text)
    ERB::Util.html_escape(text)
  end

  # ── Reusable section helpers ──

  def nav_html(links: [], cta_text: nil, cta_url: nil, bg: '#003262')
    cta_text ||= hero_cta_text
    cta_url  ||= hero_cta_url
    link_items = links.map { |l| %(<a href="#{h l[:href]}">#{h l[:label]}</a>) }.join
    cta_item = cta_url != '#' || cta_text.present? ? %(<a href="#{h cta_url}" class="btn-order">#{h cta_text}</a>) : ''
    %(<nav class="project-header" style="background:#{bg};"><div class="container"><div style="font-size:20px;font-weight:700;color:#C5A44E;">#{h book_title}</div><div class="nav-links">#{link_items}#{cta_item}</div></div></nav>)
  end

  def steps_html(steps = nil)
    steps = if @wizard_data&.dig(:steps).is_a?(Array) && @wizard_data[:steps].any?
              @wizard_data[:steps]
            elsif steps
              steps
            else
              TEMPLATE_STEPS[@template] || TEMPLATE_STEPS['personalized_video']
            end
    cards = steps.each_with_index.map do |step, i|
      step = step.symbolize_keys if step.respond_to?(:symbolize_keys)
      num = step[:number] || (i + 1).to_s
      %(<div style="flex:1;min-width:200px;text-align:center;padding:32px 20px;"><div style="width:48px;height:48px;border-radius:50%;background:#C5A44E;color:#fff;font-size:20px;font-weight:700;display:flex;align-items:center;justify-content:center;margin:0 auto 16px;">#{h num}</div><h3 style="font-size:18px;color:#003262;font-family:'Montserrat',sans-serif;margin-bottom:8px;">#{h step[:title]}</h3><p style="color:#666;font-size:14px;">#{h step[:description]}</p></div>)
    end.join
    %(<section id="steps" style="padding:60px 0;background:#f8f9fa;"><div class="container"><h2 style="font-size:36px;color:#003262;font-family:'Montserrat',sans-serif;text-align:center;margin-bottom:40px;">How It Works</h2><div style="display:flex;flex-wrap:wrap;gap:16px;justify-content:center;">#{cards}</div></div></section>)
  end

  def retailer_grid_html(retailers = nil)
    retailers = if @wizard_data&.dig(:retailers).is_a?(Array) && @wizard_data[:retailers].any?
                  @wizard_data[:retailers]
                elsif retailers
                  retailers
                else
                  DEFAULT_RETAILERS
                end
    cards = retailers.map do |r|
      r = r.symbolize_keys if r.respond_to?(:symbolize_keys)
      url = r[:url].presence || '#'
      %(<a href="#{h url}" target="_blank" rel="noopener" style="display:flex;flex-direction:column;align-items:center;justify-content:center;padding:24px 16px;border:1px solid #e5e7eb;border-radius:12px;text-decoration:none;transition:all 0.15s;"><span style="font-size:32px;margin-bottom:8px;">#{r[:icon]}</span><span style="font-size:14px;font-weight:600;color:#003262;">#{h r[:name]}</span></a>)
    end.join
    %(<section id="retailers" style="padding:60px 0;background:#fff;"><div class="container" style="max-width:900px;"><h2 style="font-size:36px;color:#003262;font-family:'Montserrat',sans-serif;text-align:center;margin-bottom:12px;">Where to Buy</h2><p style="text-align:center;color:#666;font-size:15px;margin-bottom:32px;">Order from your favorite retailer</p><div style="display:grid;grid-template-columns:repeat(auto-fit,minmax(140px,1fr));gap:16px;">#{cards}</div></div></section>)
  end

  def order_form_html
    %(<section id="order-form" style="padding:60px 0;background:#f8f9fa;"><div class="container" style="max-width:600px;"><h2 style="font-size:28px;color:#003262;font-family:'Montserrat',sans-serif;text-align:center;margin-bottom:8px;">Submit Your Receipt</h2><p style="text-align:center;color:#666;font-size:15px;margin-bottom:32px;">Upload your proof of purchase to claim your reward.</p><form class="page-form" data-form="receipt"><div style="display:grid;grid-template-columns:1fr 1fr;gap:16px;margin-bottom:16px;"><div><label style="display:block;font-size:13px;font-weight:600;margin-bottom:4px;">First Name</label><input type="text" name="first_name" required style="width:100%;padding:10px;border:1px solid #ddd;border-radius:8px;font-size:14px;"></div><div><label style="display:block;font-size:13px;font-weight:600;margin-bottom:4px;">Last Name</label><input type="text" name="last_name" required style="width:100%;padding:10px;border:1px solid #ddd;border-radius:8px;font-size:14px;"></div></div><div style="margin-bottom:16px;"><label style="display:block;font-size:13px;font-weight:600;margin-bottom:4px;">Email</label><input type="email" name="email" required style="width:100%;padding:10px;border:1px solid #ddd;border-radius:8px;font-size:14px;"></div><div style="margin-bottom:16px;"><label style="display:block;font-size:13px;font-weight:600;margin-bottom:4px;">Retailer</label><select name="retailer" required style="width:100%;padding:10px;border:1px solid #ddd;border-radius:8px;font-size:14px;background:#fff;"><option value="">Select retailer...</option><option>Amazon</option><option>Barnes &amp; Noble</option><option>Bookshop.org</option><option>Target</option><option>Walmart</option><option>Books-A-Million</option><option>Other</option></select></div><div style="margin-bottom:24px;"><label style="display:block;font-size:13px;font-weight:600;margin-bottom:4px;">Receipt / Screenshot</label><input type="file" name="receipt" accept="image/*,.pdf" style="width:100%;padding:10px;border:1px solid #ddd;border-radius:8px;font-size:14px;background:#fff;"></div><button type="submit" class="btn order-btn" style="width:100%;padding:14px;font-size:16px;border:none;border-radius:8px;cursor:pointer;">Submit Receipt</button></form></div></section>)
  end

  def testimonials_html(quotes = nil)
    quotes = if @wizard_data&.dig(:testimonials).is_a?(Array) && @wizard_data[:testimonials].any?
               @wizard_data[:testimonials]
             elsif quotes
               quotes
             else
               DEFAULT_TESTIMONIAL
             end
    cards = quotes.map do |q|
      q = q.symbolize_keys if q.respond_to?(:symbolize_keys)
      %(<div style="flex:1;min-width:280px;padding:32px;background:#fff;border-radius:12px;box-shadow:0 2px 12px rgba(0,0,0,0.06);"><p style="font-size:16px;color:#333;line-height:1.7;font-style:italic;">#{h q[:quote]}</p><p style="margin-top:16px;font-size:14px;color:#C5A44E;font-weight:600;">#{h q[:attribution]}</p></div>)
    end.join
    %(<section id="testimonials" style="padding:60px 0;background:#f0f2f7;"><div class="container"><h2 style="font-size:36px;color:#003262;font-family:'Montserrat',sans-serif;text-align:center;margin-bottom:32px;">What Readers Are Saying</h2><div style="display:flex;flex-wrap:wrap;gap:24px;justify-content:center;">#{cards}</div></div></section>)
  end

  def bonus_cards_html(bonuses = nil)
    bonuses = if @wizard_data&.dig(:bonuses).is_a?(Array) && @wizard_data[:bonuses].any?
                @wizard_data[:bonuses]
              elsif bonuses
                bonuses
              else
                DEFAULT_BONUSES
              end
    cards = bonuses.map do |b|
      b = b.symbolize_keys if b.respond_to?(:symbolize_keys)
      %(<div style="padding:24px;border:1px solid #e5e7eb;border-radius:12px;text-align:center;"><div style="font-size:32px;margin-bottom:12px;">#{b[:emoji]}</div><h3 style="color:#003262;font-size:16px;">#{h b[:title]}</h3><p style="color:#888;font-size:13px;margin-top:6px;">#{h b[:description]}</p></div>)
    end.join
    %(<section id="bonuses" style="padding:60px 0;background:#fff;"><div class="container" style="max-width:800px;text-align:center;"><h2 style="font-size:36px;color:#003262;font-family:'Montserrat',sans-serif;margin-bottom:16px;">Pre-Order Bonus</h2><p style="font-size:18px;color:#666;margin-bottom:32px;">Pre-order before #{h release_date} and receive exclusive bonus content.</p><div style="display:grid;grid-template-columns:repeat(auto-fit,minmax(200px,1fr));gap:24px;">#{cards}</div></div></section>)
  end

  def book_section_html
    %(<section id="book" class="book-section"><div class="container"><div class="book-row"><div class="book-cover">#{book_cover_html}</div><div class="book-detail"><h3 class="book-headline1"><strong>About</strong> The Book</h3><h4 class="book-headline2">#{h genre} — #{h release_date}</h4><div class="book-desc"><p>#{h book_description}</p></div></div></div></div></section>)
  end

  def author_section_html
    %(<section id="author" class="author-section"><div class="container"><div class="author-row"><div class="author-image">#{author_image_html}</div><div class="author-detail"><h3 class="author-headline1"><strong>About</strong> #{h author_name}</h3><div class="author-desc"><p>#{h author_bio}</p></div></div></div></div></section>)
  end

  def footer_html(bg: '#003262')
    %(<footer class="launch-footer" style="background:#{bg};"><div class="container"><span>&copy; #{Time.current.year} #{h author_name}. All Rights Reserved.</span><span><a href="#">Privacy Policy</a></span></div></footer>)
  end

  # ── Template builders ──

  def build_html
    case @template
    when 'personalized_video'  then build_personalized_video_html
    when 'preorder_incentive'  then build_preorder_incentive_html
    when 'address_capture'     then build_address_capture_html
    when 'landing_page'        then build_landing_page_html
    when 'vinyl'               then build_vinyl_html
    else build_standard_html
    end
  end

  def build_standard_html
    <<~HTML
      #{company_bar_html}#{nav_html(links: [{ href: '#book', label: 'The Book' }, { href: '#author', label: 'The Author' }])}
      <section class="section-wrapper section-intro" style="background-image:linear-gradient(135deg,rgba(0,50,98,0.92),rgba(0,30,60,0.95));background-size:cover;background-position:center center;display:flex;align-items:center;justify-content:center;text-align:center;color:#fff;"><div class="container" style="padding-top:60px;padding-bottom:60px;"><h1 class="page-headline text-shadow" style="color:#fff;">#{h book_title}</h1><p style="font-size:24px;margin-top:16px;color:rgba(255,255,255,0.85);text-shadow:1px 1px 2px #000;">#{h hero_subheadline}</p><a href="#{h hero_cta_url}" class="btn order-btn" style="margin-top:28px;font-size:18px;padding:14px 40px;">#{h hero_cta_text}</a></div></section>
      #{book_section_html}
      #{author_section_html}
      #{testimonials_html}
      #{footer_html}
    HTML
  end

  def build_personalized_video_html
    <<~HTML
      #{company_bar_html}#{nav_html(links: [{ href: '#steps', label: 'How It Works' }, { href: '#retailers', label: 'Retailers' }, { href: '#book', label: 'The Book' }])}
      <section class="section-wrapper section-intro" style="background:linear-gradient(135deg,rgba(0,50,98,0.92),rgba(0,30,60,0.95));text-align:center;color:#fff;padding:80px 0;"><div class="container"><h1 class="page-headline text-shadow" style="color:#fff;font-size:48px;">#{h book_title}</h1><p style="font-size:20px;margin-top:16px;color:rgba(255,255,255,0.85);">#{h hero_subheadline}</p><p style="font-size:16px;margin-top:12px;color:rgba(255,255,255,0.7);">Order the book, submit your receipt, and receive a personalized video from #{h author_name}</p><a href="#steps" class="btn order-btn" style="margin-top:28px;font-size:18px;padding:14px 40px;">#{h hero_cta_text}</a></div></section>
      <section id="video" style="padding:50px 0;background:#fff;"><div class="container" style="max-width:800px;text-align:center;"><div style="background:#000;border-radius:12px;aspect-ratio:16/9;display:flex;align-items:center;justify-content:center;color:#666;font-size:18px;margin-bottom:24px;">Video Player — Upload a recording in Campaign Assets</div><p style="color:#666;font-size:14px;">Personalized video from #{h author_name}</p></div></section>
      #{steps_html}
      #{retailer_grid_html}
      #{order_form_html}
      #{book_section_html}
      #{author_section_html}
      #{testimonials_html}
      #{footer_html}
    HTML
  end

  def build_preorder_incentive_html
    <<~HTML
      #{company_bar_html}#{nav_html(links: [{ href: '#bonuses', label: 'Bonus' }, { href: '#steps', label: 'How It Works' }, { href: '#retailers', label: 'Retailers' }])}
      <section class="section-wrapper section-intro" style="background:linear-gradient(135deg,rgba(0,50,98,0.92),rgba(0,30,60,0.95));text-align:center;color:#fff;padding:80px 0;"><div class="container"><p style="font-size:16px;text-transform:uppercase;letter-spacing:3px;color:#C5A44E;margin-bottom:16px;">Available #{h release_date}</p><h1 class="page-headline text-shadow" style="color:#fff;font-size:56px;">#{h book_title}</h1><p style="font-size:22px;margin-top:16px;color:rgba(255,255,255,0.85);">#{h hero_subheadline}</p><a href="#{h hero_cta_url}" class="btn order-btn" style="margin-top:28px;font-size:18px;padding:14px 40px;">#{h hero_cta_text}</a></div></section>
      #{bonus_cards_html}
      #{steps_html}
      #{retailer_grid_html}
      #{order_form_html}
      #{book_section_html}
      #{footer_html}
    HTML
  end

  def build_address_capture_html
    <<~HTML
      #{company_bar_html}#{nav_html(links: [{ href: '#signup', label: 'Get Your Copy' }, { href: '#book', label: 'The Book' }], cta_text: nil, cta_url: nil)}
      <section class="section-wrapper section-intro" style="background:linear-gradient(135deg,rgba(0,50,98,0.92),rgba(0,30,60,0.95));text-align:center;color:#fff;padding:80px 0;"><div class="container"><h1 class="page-headline text-shadow" style="color:#fff;font-size:48px;">#{h book_title}</h1><p style="font-size:20px;margin-top:16px;color:rgba(255,255,255,0.85);">#{h hero_subheadline}</p></div></section>
      <section id="signup" style="padding:60px 0;background:#fff;"><div class="container" style="max-width:600px;"><h2 style="font-size:28px;color:#003262;font-family:'Montserrat',sans-serif;text-align:center;margin-bottom:8px;">Claim Your Signed Copy</h2><p style="text-align:center;color:#666;font-size:15px;margin-bottom:32px;">Enter your shipping address to receive your personally signed edition.</p><form class="page-form" data-form="address"><div style="display:grid;grid-template-columns:1fr 1fr;gap:16px;margin-bottom:16px;"><div><label style="display:block;font-size:13px;font-weight:600;margin-bottom:4px;">First Name</label><input type="text" name="first_name" required style="width:100%;padding:10px;border:1px solid #ddd;border-radius:8px;font-size:14px;"></div><div><label style="display:block;font-size:13px;font-weight:600;margin-bottom:4px;">Last Name</label><input type="text" name="last_name" required style="width:100%;padding:10px;border:1px solid #ddd;border-radius:8px;font-size:14px;"></div></div><div style="margin-bottom:16px;"><label style="display:block;font-size:13px;font-weight:600;margin-bottom:4px;">Email</label><input type="email" name="email" required style="width:100%;padding:10px;border:1px solid #ddd;border-radius:8px;font-size:14px;"></div><div style="margin-bottom:16px;"><label style="display:block;font-size:13px;font-weight:600;margin-bottom:4px;">Street Address</label><input type="text" name="address" required style="width:100%;padding:10px;border:1px solid #ddd;border-radius:8px;font-size:14px;"></div><div style="display:grid;grid-template-columns:2fr 1fr 1fr;gap:16px;margin-bottom:24px;"><div><label style="display:block;font-size:13px;font-weight:600;margin-bottom:4px;">City</label><input type="text" name="city" required style="width:100%;padding:10px;border:1px solid #ddd;border-radius:8px;font-size:14px;"></div><div><label style="display:block;font-size:13px;font-weight:600;margin-bottom:4px;">State</label><input type="text" name="state" required style="width:100%;padding:10px;border:1px solid #ddd;border-radius:8px;font-size:14px;"></div><div><label style="display:block;font-size:13px;font-weight:600;margin-bottom:4px;">ZIP</label><input type="text" name="zip" required style="width:100%;padding:10px;border:1px solid #ddd;border-radius:8px;font-size:14px;"></div></div><button type="submit" class="btn order-btn" style="width:100%;padding:14px;font-size:16px;border:none;border-radius:8px;cursor:pointer;">Submit Address</button></form></div></section>
      #{book_section_html}
      #{author_section_html}
      #{footer_html}
    HTML
  end

  def build_landing_page_html
    <<~HTML
      #{company_bar_html}#{nav_html(links: [{ href: '#book', label: 'The Book' }, { href: '#author', label: 'The Author' }, { href: '#retailers', label: 'Buy' }, { href: '#signup', label: 'Get Notified' }])}
      <section class="section-wrapper section-intro" style="background:linear-gradient(135deg,rgba(0,50,98,0.92),rgba(0,30,60,0.95));text-align:center;color:#fff;padding:100px 0;"><div class="container"><h1 class="page-headline text-shadow" style="color:#fff;font-size:64px;">#{h book_title}</h1><p style="font-size:24px;margin-top:16px;color:rgba(255,255,255,0.85);">#{h hero_subheadline}</p><p style="font-size:16px;margin-top:8px;color:#C5A44E;">#{h genre} — #{h release_date}</p></div></section>
      #{book_section_html}
      #{author_section_html}
      #{retailer_grid_html}
      #{testimonials_html}
      <section id="signup" style="padding:60px 0;background:#fff;text-align:center;"><div class="container" style="max-width:500px;"><h2 style="font-size:28px;color:#003262;font-family:'Montserrat',sans-serif;margin-bottom:8px;">Stay Updated</h2><p style="color:#666;font-size:15px;margin-bottom:24px;">Be the first to know about release dates, signed editions, and events.</p><form class="page-form" data-form="notify"><div style="display:flex;gap:12px;"><input type="email" name="email" required placeholder="your@email.com" style="flex:1;padding:12px;border:1px solid #ddd;border-radius:8px;font-size:14px;"><button type="submit" class="btn order-btn" style="padding:12px 24px;border:none;border-radius:8px;cursor:pointer;white-space:nowrap;">Notify Me</button></div></form></div></section>
      #{footer_html}
    HTML
  end

  def build_vinyl_html
    <<~HTML
      #{company_bar_html}#{nav_html(links: [{ href: '#release', label: 'The Release' }, { href: '#artist', label: 'The Artist' }], bg: '#111')}
      <section class="section-wrapper section-intro" style="background:linear-gradient(135deg,#111,#1a1a2e);text-align:center;color:#fff;padding:100px 0;"><div class="container"><p style="font-size:14px;text-transform:uppercase;letter-spacing:4px;color:#C5A44E;margin-bottom:20px;">New Release</p><h1 class="page-headline" style="color:#fff;font-size:64px;">#{h book_title}</h1><p style="font-size:22px;margin-top:16px;color:rgba(255,255,255,0.7);">#{h author_name}</p><a href="#{h hero_cta_url}" class="btn order-btn" style="margin-top:32px;font-size:18px;padding:14px 40px;">#{h hero_cta_text}</a></div></section>
      <section id="release" style="padding:60px 0;background:#fff;"><div class="container"><div style="display:flex;flex-wrap:wrap;gap:40px;align-items:center;"><div style="flex:0 0 300px;">#{book_cover_html}</div><div style="flex:1;min-width:280px;"><h2 style="font-size:36px;color:#111;font-family:'Montserrat',sans-serif;">About the Release</h2><p style="color:#C5A44E;font-weight:600;margin:12px 0;">#{h genre} — #{h release_date}</p><p style="color:#555;font-size:15px;line-height:1.8;">#{h book_description}</p></div></div></div></section>
      <section id="artist" class="author-section" style="background:#f5f5f5;"><div class="container"><div class="author-row"><div class="author-image">#{author_image_html}</div><div class="author-detail"><h3 class="author-headline1"><strong>About</strong> #{h author_name}</h3><div class="author-desc"><p>#{h author_bio}</p></div></div></div></div></section>
      #{testimonials_html}
      #{footer_html(bg: '#111')}
    HTML
  end

  def build_css
    <<~CSS
      @import url('https://fonts.googleapis.com/css2?family=Open+Sans:wght@300;400;600;700;800&family=Montserrat:wght@300;400;500;600;700;800&family=Inter:wght@300;400;500;600;700&display=swap');
      *{box-sizing:border-box;margin:0;padding:0}body{font-family:'Open Sans',sans-serif;color:#18191f}img{max-width:100%}a{text-decoration:none}
      .section-wrapper{background-size:cover;background-position:center center;background-repeat:no-repeat;width:100%}.section-intro{padding-top:120px;min-height:90vh}
      .page-headline{font-size:74px;font-weight:800;line-height:80px}.text-shadow{text-shadow:1px 1px 2px #000}
      .btn{display:inline-block;padding:11px 32px;border-radius:4px;font-weight:600;cursor:pointer;border:none}.order-btn{background:#C5A44E;color:#fff;font-size:16px}.order-btn:hover{opacity:0.9}.btn-order{background:#C5A44E;color:#fff!important;padding:8px 20px;border-radius:4px;font-size:14px}
      .project-header{background:#003262;padding:12px 0;position:relative;z-index:100}.project-header .container{max-width:1140px;margin:0 auto;padding:0 15px;display:flex;align-items:center;justify-content:space-between}.project-header .nav-links{display:flex;gap:24px;align-items:center}.project-header .nav-links a{color:rgba(255,255,255,0.85);font-size:14px;font-weight:500}.project-header .nav-links a:hover{color:#C5A44E}
      .book-section{padding:50px 0}.book-section .container{max-width:1140px;margin:0 auto;padding:0 15px}.book-row{display:flex;flex-wrap:wrap;gap:30px}.book-cover{flex:0 0 33%;min-width:250px}.book-cover img{width:100%;box-shadow:0 4px 20px rgba(0,0,0,0.15)}.book-detail{flex:1;min-width:300px}.book-headline1{font-size:50px;font-weight:300;line-height:55px;color:#003262;font-family:'Montserrat',sans-serif}.book-headline1 strong{font-weight:700}.book-headline2{color:#C5A44E;font-weight:600;font-size:18px;line-height:28px;margin:12px 0}.book-desc{color:#444;font-size:14px;line-height:25px}
      .author-section{padding:50px 0;background:#f0f2f7}.author-section .container{max-width:1140px;margin:0 auto;padding:0 15px}.author-row{display:flex;flex-wrap:wrap;gap:30px}.author-image{flex:0 0 33%;min-width:250px;min-height:400px}.author-image img{width:100%}.author-detail{flex:1;min-width:300px}.author-headline1{font-size:50px;font-weight:300;line-height:55px;color:#003262;font-family:'Montserrat',sans-serif}.author-headline1 strong{font-weight:700}.author-desc{color:#444;font-size:14px;line-height:25px;margin-top:12px}
      .launch-footer{background:#003262;color:rgba(255,255,255,0.6);padding:20px 0;font-size:12px}.launch-footer .container{max-width:1140px;margin:0 auto;padding:0 15px;display:flex;justify-content:space-between;align-items:center;flex-wrap:wrap}.launch-footer a{color:#C5A44E}
      .company-bar{background:#001f3f;color:#fff;padding:10px 0;font-size:13px;text-align:center}.company-bar a{color:#C5A44E}
      .container{max-width:1140px;margin:0 auto;padding:0 15px}
      @media(max-width:480px){.page-headline{font-size:36px;line-height:42px}.book-row,.author-row{flex-direction:column}.book-cover,.author-image{flex:none;width:100%;min-width:0}.author-image{min-height:auto}}
    CSS
  end
end
