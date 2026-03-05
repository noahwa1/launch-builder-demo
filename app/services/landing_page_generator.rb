class LandingPageGenerator
  # Campaign mode:   LandingPageGenerator.new(campaign)
  # Standalone mode:  LandingPageGenerator.new(nil, author: author, book: book, company_name: "Acme", company_email: "hi@acme.com")
  def initialize(campaign, author: nil, book: nil, company_name: nil, company_email: nil)
    @campaign = campaign
    @company_name = company_name
    @company_email = company_email

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
    email_html = @company_email.present? ? %( — <a href="mailto:#{h @company_email}" style="color:#2F80ED;">#{h @company_email}</a>) : ''
    %(<div class="company-bar"><div class="container">Offered by <strong>#{h @company_name}</strong>#{email_html}</div></div>)
  end

  def h(text)
    ERB::Util.html_escape(text)
  end

  def build_html
    <<~HTML
      #{company_bar_html}<nav class="project-header"><div class="container"><div style="font-size:20px;font-weight:700;color:#333;">#{h book_title}</div><div class="nav-links"><a href="#book">The Book</a><a href="#author">The Author</a><a href="#{h purchase_url}" class="btn-order">Order Now</a></div></div></nav>
      <section class="section-wrapper section-intro" style="background-image:linear-gradient(135deg,rgba(0,42,86,0.85),rgba(26,26,46,0.9));background-size:cover;background-position:center center;display:flex;align-items:center;justify-content:center;text-align:center;color:#fff;"><div class="container" style="padding-top:60px;padding-bottom:60px;"><h1 class="page-headline text-shadow" style="color:#fff;">#{h book_title}</h1><p style="font-size:24px;margin-top:16px;color:rgba(255,255,255,0.85);text-shadow:1px 1px 2px #000;">by #{h author_name}</p><a href="#{h purchase_url}" class="btn order-btn" style="margin-top:28px;font-size:18px;padding:14px 40px;">Order Your Copy</a></div></section>
      <section id="book" class="book-section"><div class="container"><div class="book-row"><div class="book-cover">#{book_cover_html}</div><div class="book-detail"><h3 class="book-headline1"><strong>About</strong> The Book</h3><h4 class="book-headline2">#{h genre} — #{h release_date}</h4><div class="book-desc"><p>#{h book_description}</p></div></div></div></div></section>
      <section id="author" class="author-section"><div class="container"><div class="author-row"><div class="author-image">#{author_image_html}</div><div class="author-detail"><h3 class="author-headline1"><strong>About</strong> #{h author_name}</h3><div class="author-desc"><p>#{h author_bio}</p></div></div></div></div></section>
      <footer class="launch-footer"><div class="container"><span>&copy; #{Time.current.year} #{h author_name}. All Rights Reserved.</span><span><a href="#">Privacy Policy</a></span></div></footer>
    HTML
  end

  def build_css
    <<~CSS
      @import url('https://fonts.googleapis.com/css2?family=Open+Sans:wght@300;400;600;700;800&family=Montserrat:wght@300;400;500;600;700;800&family=Inter:wght@300;400;500;600;700&display=swap');
      *{box-sizing:border-box;margin:0;padding:0}body{font-family:'Open Sans',sans-serif;color:#18191f}img{max-width:100%}a{text-decoration:none}
      .section-wrapper{background-size:cover;background-position:center center;background-repeat:no-repeat;width:100%}.section-intro{padding-top:120px;min-height:90vh}
      .page-headline{font-size:74px;font-weight:800;line-height:80px}.text-shadow{text-shadow:1px 1px 2px #000}
      .btn{display:inline-block;padding:11px 32px;border-radius:4px;font-weight:600;cursor:pointer;border:none}.order-btn{background:#219653;color:#fff;font-size:16px}.order-btn:hover{opacity:0.9}.btn-order{background:#219653;color:#fff!important;padding:8px 20px;border-radius:4px;font-size:14px}
      .project-header{background:rgba(255,255,255,0.95);padding:12px 0;position:relative;z-index:100}.project-header .container{max-width:1140px;margin:0 auto;padding:0 15px;display:flex;align-items:center;justify-content:space-between}.project-header .nav-links{display:flex;gap:24px;align-items:center}.project-header .nav-links a{color:#18191f;font-size:14px;font-weight:500}
      .book-section{padding:50px 0}.book-section .container{max-width:1140px;margin:0 auto;padding:0 15px}.book-row{display:flex;flex-wrap:wrap;gap:30px}.book-cover{flex:0 0 33%;min-width:250px}.book-cover img{width:100%;box-shadow:0 4px 20px rgba(0,0,0,0.15)}.book-detail{flex:1;min-width:300px}.book-headline1{font-size:50px;font-weight:300;line-height:55px;color:#121212;font-family:'Montserrat',sans-serif}.book-headline1 strong{font-weight:700}.book-headline2{color:#2c2c2c;font-weight:600;font-size:18px;line-height:28px;margin:12px 0}.book-desc{color:#4a4a4a;font-size:14px;line-height:25px}
      .author-section{padding:50px 0;background:#f7f8fa}.author-section .container{max-width:1140px;margin:0 auto;padding:0 15px}.author-row{display:flex;flex-wrap:wrap;gap:30px}.author-image{flex:0 0 33%;min-width:250px;min-height:400px}.author-image img{width:100%}.author-detail{flex:1;min-width:300px}.author-headline1{font-size:50px;font-weight:300;line-height:55px;color:#121212;font-family:'Montserrat',sans-serif}.author-headline1 strong{font-weight:700}.author-desc{color:#4a4a4a;font-size:14px;line-height:25px;margin-top:12px}
      .launch-footer{background:#29292d;color:#888;padding:20px 0;font-size:12px}.launch-footer .container{max-width:1140px;margin:0 auto;padding:0 15px;display:flex;justify-content:space-between;align-items:center;flex-wrap:wrap}.launch-footer a{color:#2F80ED}
      .company-bar{background:#1a1a2e;color:#fff;padding:10px 0;font-size:13px;text-align:center}.company-bar a{color:#2F80ED}
      .container{max-width:1140px;margin:0 auto;padding:0 15px}
      @media(max-width:480px){.page-headline{font-size:36px;line-height:42px}.book-row,.author-row{flex-direction:column}.book-cover,.author-image{flex:none;width:100%;min-width:0}.author-image{min-height:auto}}
    CSS
  end
end
