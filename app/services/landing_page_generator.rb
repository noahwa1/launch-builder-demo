class LandingPageGenerator
  TEMPLATES = {
    'standard'            => 'Standard',
    'personalized_video'  => 'Personalized Video',
    'preorder_incentive'  => 'Preorder Incentive',
    'address_capture'     => 'Address Capture',
    'landing_page'        => 'Landing Page',
    'vinyl'               => 'Vinyl / Music'
  }.freeze

  # Campaign mode:   LandingPageGenerator.new(campaign)
  # Standalone mode:  LandingPageGenerator.new(nil, author: author, book: book, company_name: "Acme", company_email: "hi@acme.com")
  def initialize(campaign, author: nil, book: nil, company_name: nil, company_email: nil, template: 'standard')
    @campaign = campaign
    @company_name = company_name
    @company_email = company_email
    @template = TEMPLATES.key?(template.to_s) ? template.to_s : 'standard'

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

  def book_title
    if @submission
      @submission.title || 'Your Book Title'
    elsif @book
      @book.title || 'Your Book Title'
    else
      'Your Book Title'
    end
  end

  def book_description
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
    @author&.full_name || 'Author Name'
  end

  def author_bio
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
    @submission&.genre || 'General'
  end

  def release_date
    date = @submission&.release_date || @book&.release_date
    date&.strftime('%B %d, %Y') || 'Coming Soon'
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
      #{company_bar_html}<nav class="project-header"><div class="container"><div style="font-size:20px;font-weight:700;color:#C5A44E;">#{h book_title}</div><div class="nav-links"><a href="#book">The Book</a><a href="#author">The Author</a><a href="#{h purchase_url}" class="btn-order">Order Now</a></div></div></nav>
      <section class="section-wrapper section-intro" style="background-image:linear-gradient(135deg,rgba(0,50,98,0.92),rgba(0,30,60,0.95));background-size:cover;background-position:center center;display:flex;align-items:center;justify-content:center;text-align:center;color:#fff;"><div class="container" style="padding-top:60px;padding-bottom:60px;"><h1 class="page-headline text-shadow" style="color:#fff;">#{h book_title}</h1><p style="font-size:24px;margin-top:16px;color:rgba(255,255,255,0.85);text-shadow:1px 1px 2px #000;">by #{h author_name}</p><a href="#{h purchase_url}" class="btn order-btn" style="margin-top:28px;font-size:18px;padding:14px 40px;">Order Your Copy</a></div></section>
      <section id="book" class="book-section"><div class="container"><div class="book-row"><div class="book-cover">#{book_cover_html}</div><div class="book-detail"><h3 class="book-headline1"><strong>About</strong> The Book</h3><h4 class="book-headline2">#{h genre} — #{h release_date}</h4><div class="book-desc"><p>#{h book_description}</p></div></div></div></div></section>
      <section id="author" class="author-section"><div class="container"><div class="author-row"><div class="author-image">#{author_image_html}</div><div class="author-detail"><h3 class="author-headline1"><strong>About</strong> #{h author_name}</h3><div class="author-desc"><p>#{h author_bio}</p></div></div></div></div></section>
      <footer class="launch-footer"><div class="container"><span>&copy; #{Time.current.year} #{h author_name}. All Rights Reserved.</span><span><a href="#">Privacy Policy</a></span></div></footer>
    HTML
  end

  def build_personalized_video_html
    <<~HTML
      #{company_bar_html}<nav class="project-header"><div class="container"><div style="font-size:20px;font-weight:700;color:#C5A44E;">#{h book_title}</div><div class="nav-links"><a href="#video">Video Message</a><a href="#book">The Book</a><a href="#{h purchase_url}" class="btn-order">Order Now</a></div></div></nav>
      <section class="section-wrapper section-intro" style="background:linear-gradient(135deg,rgba(0,50,98,0.92),rgba(0,30,60,0.95));text-align:center;color:#fff;padding:80px 0;"><div class="container"><h1 class="page-headline text-shadow" style="color:#fff;font-size:48px;">A Personal Message from #{h author_name}</h1><p style="font-size:20px;margin-top:16px;color:rgba(255,255,255,0.85);">Watch the video below for a special message about <em>#{h book_title}</em></p></div></section>
      <section id="video" style="padding:50px 0;background:#f8f9fa;"><div class="container" style="max-width:800px;text-align:center;"><div style="background:#000;border-radius:12px;aspect-ratio:16/9;display:flex;align-items:center;justify-content:center;color:#666;font-size:18px;margin-bottom:24px;">Video Player — Upload a recording in Campaign Assets</div><p style="color:#666;font-size:14px;">Personalized video from #{h author_name}</p></div></section>
      <section id="book" class="book-section"><div class="container"><div class="book-row"><div class="book-cover">#{book_cover_html}</div><div class="book-detail"><h3 class="book-headline1"><strong>About</strong> The Book</h3><h4 class="book-headline2">#{h genre} — #{h release_date}</h4><div class="book-desc"><p>#{h book_description}</p></div><a href="#{h purchase_url}" class="btn order-btn" style="margin-top:20px;display:inline-block;">Order Your Copy</a></div></div></div></section>
      <footer class="launch-footer"><div class="container"><span>&copy; #{Time.current.year} #{h author_name}. All Rights Reserved.</span><span><a href="#">Privacy Policy</a></span></div></footer>
    HTML
  end

  def build_preorder_incentive_html
    <<~HTML
      #{company_bar_html}<nav class="project-header"><div class="container"><div style="font-size:20px;font-weight:700;color:#C5A44E;">#{h book_title}</div><div class="nav-links"><a href="#preorder">Pre-Order</a><a href="#incentive">Bonus</a><a href="#{h purchase_url}" class="btn-order">Pre-Order Now</a></div></div></nav>
      <section class="section-wrapper section-intro" style="background:linear-gradient(135deg,rgba(0,50,98,0.92),rgba(0,30,60,0.95));text-align:center;color:#fff;padding:80px 0;"><div class="container"><p style="font-size:16px;text-transform:uppercase;letter-spacing:3px;color:#C5A44E;margin-bottom:16px;">Available #{h release_date}</p><h1 class="page-headline text-shadow" style="color:#fff;font-size:56px;">#{h book_title}</h1><p style="font-size:22px;margin-top:16px;color:rgba(255,255,255,0.85);">by #{h author_name}</p><a href="#{h purchase_url}" class="btn order-btn" style="margin-top:28px;font-size:18px;padding:14px 40px;">Pre-Order Now</a></div></section>
      <section id="incentive" style="padding:60px 0;background:#fff;"><div class="container" style="max-width:800px;text-align:center;"><h2 style="font-size:36px;color:#003262;font-family:'Montserrat',sans-serif;margin-bottom:16px;">Pre-Order Bonus</h2><p style="font-size:18px;color:#666;margin-bottom:32px;">Pre-order before #{h release_date} and receive exclusive bonus content.</p><div style="display:grid;grid-template-columns:repeat(auto-fit,minmax(200px,1fr));gap:24px;"><div style="padding:24px;border:1px solid #e5e7eb;border-radius:12px;"><div style="font-size:32px;margin-bottom:12px;">✍️</div><h3 style="color:#003262;font-size:16px;">Signed Bookplate</h3><p style="color:#888;font-size:13px;margin-top:6px;">A personal signed bookplate from the author</p></div><div style="padding:24px;border:1px solid #e5e7eb;border-radius:12px;"><div style="font-size:32px;margin-bottom:12px;">📖</div><h3 style="color:#003262;font-size:16px;">Bonus Chapter</h3><p style="color:#888;font-size:13px;margin-top:6px;">An exclusive bonus chapter not in the final book</p></div><div style="padding:24px;border:1px solid #e5e7eb;border-radius:12px;"><div style="font-size:32px;margin-bottom:12px;">🎁</div><h3 style="color:#003262;font-size:16px;">Limited Print</h3><p style="color:#888;font-size:13px;margin-top:6px;">Exclusive art print (first 500 orders)</p></div></div></div></section>
      <section id="book" class="book-section"><div class="container"><div class="book-row"><div class="book-cover">#{book_cover_html}</div><div class="book-detail"><h3 class="book-headline1"><strong>About</strong> The Book</h3><div class="book-desc"><p>#{h book_description}</p></div></div></div></div></section>
      <footer class="launch-footer"><div class="container"><span>&copy; #{Time.current.year} #{h author_name}. All Rights Reserved.</span><span><a href="#">Privacy Policy</a></span></div></footer>
    HTML
  end

  def build_address_capture_html
    <<~HTML
      #{company_bar_html}<nav class="project-header"><div class="container"><div style="font-size:20px;font-weight:700;color:#C5A44E;">#{h book_title}</div><div class="nav-links"><a href="#signup">Get Your Copy</a><a href="#book">The Book</a></div></div></nav>
      <section class="section-wrapper section-intro" style="background:linear-gradient(135deg,rgba(0,50,98,0.92),rgba(0,30,60,0.95));text-align:center;color:#fff;padding:80px 0;"><div class="container"><h1 class="page-headline text-shadow" style="color:#fff;font-size:48px;">#{h book_title}</h1><p style="font-size:20px;margin-top:16px;color:rgba(255,255,255,0.85);">by #{h author_name}</p></div></section>
      <section id="signup" style="padding:60px 0;background:#fff;"><div class="container" style="max-width:600px;"><h2 style="font-size:28px;color:#003262;font-family:'Montserrat',sans-serif;text-align:center;margin-bottom:8px;">Claim Your Signed Copy</h2><p style="text-align:center;color:#666;font-size:15px;margin-bottom:32px;">Enter your shipping address to receive your personally signed edition.</p><form class="page-form" data-form="address"><div style="display:grid;grid-template-columns:1fr 1fr;gap:16px;margin-bottom:16px;"><div><label style="display:block;font-size:13px;font-weight:600;margin-bottom:4px;">First Name</label><input type="text" name="first_name" required style="width:100%;padding:10px;border:1px solid #ddd;border-radius:8px;font-size:14px;"></div><div><label style="display:block;font-size:13px;font-weight:600;margin-bottom:4px;">Last Name</label><input type="text" name="last_name" required style="width:100%;padding:10px;border:1px solid #ddd;border-radius:8px;font-size:14px;"></div></div><div style="margin-bottom:16px;"><label style="display:block;font-size:13px;font-weight:600;margin-bottom:4px;">Email</label><input type="email" name="email" required style="width:100%;padding:10px;border:1px solid #ddd;border-radius:8px;font-size:14px;"></div><div style="margin-bottom:16px;"><label style="display:block;font-size:13px;font-weight:600;margin-bottom:4px;">Street Address</label><input type="text" name="address" required style="width:100%;padding:10px;border:1px solid #ddd;border-radius:8px;font-size:14px;"></div><div style="display:grid;grid-template-columns:2fr 1fr 1fr;gap:16px;margin-bottom:24px;"><div><label style="display:block;font-size:13px;font-weight:600;margin-bottom:4px;">City</label><input type="text" name="city" required style="width:100%;padding:10px;border:1px solid #ddd;border-radius:8px;font-size:14px;"></div><div><label style="display:block;font-size:13px;font-weight:600;margin-bottom:4px;">State</label><input type="text" name="state" required style="width:100%;padding:10px;border:1px solid #ddd;border-radius:8px;font-size:14px;"></div><div><label style="display:block;font-size:13px;font-weight:600;margin-bottom:4px;">ZIP</label><input type="text" name="zip" required style="width:100%;padding:10px;border:1px solid #ddd;border-radius:8px;font-size:14px;"></div></div><button type="submit" class="btn order-btn" style="width:100%;padding:14px;font-size:16px;border:none;border-radius:8px;cursor:pointer;">Submit Address</button></form></div></section>
      <section id="book" class="book-section"><div class="container"><div class="book-row"><div class="book-cover">#{book_cover_html}</div><div class="book-detail"><h3 class="book-headline1"><strong>About</strong> The Book</h3><div class="book-desc"><p>#{h book_description}</p></div></div></div></div></section>
      <footer class="launch-footer"><div class="container"><span>&copy; #{Time.current.year} #{h author_name}. All Rights Reserved.</span><span><a href="#">Privacy Policy</a></span></div></footer>
    HTML
  end

  def build_landing_page_html
    <<~HTML
      #{company_bar_html}<nav class="project-header"><div class="container"><div style="font-size:20px;font-weight:700;color:#C5A44E;">#{h book_title}</div><div class="nav-links"><a href="#book">The Book</a><a href="#author">The Author</a><a href="#signup">Get Notified</a></div></div></nav>
      <section class="section-wrapper section-intro" style="background:linear-gradient(135deg,rgba(0,50,98,0.92),rgba(0,30,60,0.95));text-align:center;color:#fff;padding:100px 0;"><div class="container"><h1 class="page-headline text-shadow" style="color:#fff;font-size:64px;">#{h book_title}</h1><p style="font-size:24px;margin-top:16px;color:rgba(255,255,255,0.85);">by #{h author_name}</p><p style="font-size:16px;margin-top:8px;color:#C5A44E;">#{h genre} — #{h release_date}</p></div></section>
      <section id="book" class="book-section"><div class="container"><div class="book-row"><div class="book-cover">#{book_cover_html}</div><div class="book-detail"><h3 class="book-headline1"><strong>About</strong> The Book</h3><div class="book-desc"><p>#{h book_description}</p></div></div></div></div></section>
      <section id="author" class="author-section"><div class="container"><div class="author-row"><div class="author-image">#{author_image_html}</div><div class="author-detail"><h3 class="author-headline1"><strong>About</strong> #{h author_name}</h3><div class="author-desc"><p>#{h author_bio}</p></div></div></div></div></section>
      <section id="signup" style="padding:60px 0;background:#fff;text-align:center;"><div class="container" style="max-width:500px;"><h2 style="font-size:28px;color:#003262;font-family:'Montserrat',sans-serif;margin-bottom:8px;">Stay Updated</h2><p style="color:#666;font-size:15px;margin-bottom:24px;">Be the first to know about release dates, signed editions, and events.</p><form class="page-form" data-form="notify"><div style="display:flex;gap:12px;"><input type="email" name="email" required placeholder="your@email.com" style="flex:1;padding:12px;border:1px solid #ddd;border-radius:8px;font-size:14px;"><button type="submit" class="btn order-btn" style="padding:12px 24px;border:none;border-radius:8px;cursor:pointer;white-space:nowrap;">Notify Me</button></div></form></div></section>
      <footer class="launch-footer"><div class="container"><span>&copy; #{Time.current.year} #{h author_name}. All Rights Reserved.</span><span><a href="#">Privacy Policy</a></span></div></footer>
    HTML
  end

  def build_vinyl_html
    <<~HTML
      #{company_bar_html}<nav class="project-header" style="background:#111;"><div class="container"><div style="font-size:20px;font-weight:700;color:#C5A44E;">#{h book_title}</div><div class="nav-links"><a href="#release">The Release</a><a href="#artist">The Artist</a><a href="#{h purchase_url}" class="btn-order">Order Now</a></div></div></nav>
      <section class="section-wrapper section-intro" style="background:linear-gradient(135deg,#111,#1a1a2e);text-align:center;color:#fff;padding:100px 0;"><div class="container"><p style="font-size:14px;text-transform:uppercase;letter-spacing:4px;color:#C5A44E;margin-bottom:20px;">New Release</p><h1 class="page-headline" style="color:#fff;font-size:64px;">#{h book_title}</h1><p style="font-size:22px;margin-top:16px;color:rgba(255,255,255,0.7);">#{h author_name}</p><a href="#{h purchase_url}" class="btn order-btn" style="margin-top:32px;font-size:18px;padding:14px 40px;">Order Vinyl</a></div></section>
      <section id="release" style="padding:60px 0;background:#fff;"><div class="container"><div style="display:flex;flex-wrap:wrap;gap:40px;align-items:center;"><div style="flex:0 0 300px;">#{book_cover_html}</div><div style="flex:1;min-width:280px;"><h2 style="font-size:36px;color:#111;font-family:'Montserrat',sans-serif;">About the Release</h2><p style="color:#C5A44E;font-weight:600;margin:12px 0;">#{h genre} — #{h release_date}</p><p style="color:#555;font-size:15px;line-height:1.8;">#{h book_description}</p></div></div></div></section>
      <section id="artist" class="author-section" style="background:#f5f5f5;"><div class="container"><div class="author-row"><div class="author-image">#{author_image_html}</div><div class="author-detail"><h3 class="author-headline1"><strong>About</strong> #{h author_name}</h3><div class="author-desc"><p>#{h author_bio}</p></div></div></div></div></section>
      <footer class="launch-footer" style="background:#111;"><div class="container"><span>&copy; #{Time.current.year} #{h author_name}. All Rights Reserved.</span><span><a href="#">Privacy Policy</a></span></div></footer>
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
