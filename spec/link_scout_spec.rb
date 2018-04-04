RSpec.describe LinkScout do

  def expect_redirect_loop_error(options={})
    expect{LinkScout::run('http://301-forever.com', options)}.to raise_error(LinkScout::RedirectLoopError)
  end

  before do
    stub_request(:get, 'http://200.com').to_return(status: 200, body: "abc", headers: {})
    stub_request(:get, 'http://301.com').to_return(:status => 301, :headers => { 'Location' => "http://200.com" })
    stub_request(:get, 'http://301-forever.com').to_return(:status => 301, :headers => { 'Location' => "http://301-forever.com" })
    stub_request(:get, 'http://500.com').to_return(:status => 500)
    stub_request(:get, 'http://deep.com').to_return(:status => 301, :headers => { 'Location' => "http://200.com" })
    stub_request(:get, 'http://deep-error.com').to_return(:status => 301, :headers => { 'Location' => "http://500.com" })
  end

  it 'has a version number' do
    expect(LinkScout::VERSION).not_to be nil
  end

  it 'throws a InvalidUsage error if wrong params provided' do
    expect{LinkScout::run({})}.to raise_error(LinkScout::InvalidUsageError)
  end

  it 'throws a RedirectLoopError on too many redirects' do
    expect_redirect_loop_error
  end

  it 'succeeds on reasonable redirects' do
    expect(LinkScout::run('http://301.com')).to eq(true)
  end

  context 'options' do
    context ':url' do
      it 'succeeds' do
        expect(LinkScout::run(url: 'http://200.com')).to eq(true)
      end

      it 'throws exception if not set' do
        expect{LinkScout::run({})}.to raise_error(LinkScout::InvalidUsageError)
      end
    end

    context ':success' do
      it 'succeeds with defaults' do
        expect(LinkScout::run('http://200.com')).to eq(true)
      end

      it 'succeeds when matched' do
        expect(LinkScout::run('http://500.com', success: 500)).to eq(true)
      end

      it 'fails when not matched' do
        expect(LinkScout::run('http://500.com', success: 301)).to eq(false)
      end
    end

    context ':follow' do
      it 'succeeds with defaults' do
        expect(LinkScout::run('http://301.com', success: 200)).to eq(true)
      end
      it 'succeeds if set to true' do
        expect(LinkScout::run('http://301.com', follow: true, success: 200)).to eq(true)
      end
      it 'succeeds if set to false and success code is 301' do
        expect(LinkScout::run('http://301.com', follow: false, success: 301)).to eq(true)
      end
    end

    context ':limit' do
      it 'succeeds to stop loop with default' do
        expect_redirect_loop_error
      end

      it 'succeeds to stop loop when set' do
        expect_redirect_loop_error(limit: 1)
      end

      it 'succeeds to stop loop when nil' do
        expect_redirect_loop_error(limit: nil)
      end
    end

    context ':target' do
      it 'succeeds if set' do
        expect(LinkScout::run('http://200.com', target: 'http://200.com')).to eq(true)
      end
      it 'succeeds on redirects' do
        expect(LinkScout::run('http://301.com', target: 'http://200.com')).to eq(true)
      end
      it 'fails if not matched' do
        expect(LinkScout::run('http://200.com', target: 'http://500.com')).to eq(false)
      end
    end

    context ':deeplink_param' do
      it 'succeeds if matched' do
        expect(LinkScout::run('http://deep.com/?p=http%3A%2F%2F200.com', deeplink_param: 'p')).to eq(true)
      end
      it 'fails if not matched' do
        expect(LinkScout::run('http://deep.com/?p=http%3A%2F%2F500.com', deeplink_param: 'p')).to eq(false)
      end
      it 'fails if matched but status == 500' do
        expect(LinkScout::run('http://deep-error.com/?p=http%3A%2F%2F500.com', deeplink_param: 'p')).to eq(false)
      end
      it 'succeeds if matched and status == 500 but success == 500' do
        expect(LinkScout::run('http://deep-error.com/?p=http%3A%2F%2F500.com', deeplink_param: 'p', success: 500)).to eq(true)
      end
    end

    context ':pattern' do
      it 'succeeds if matched' do
        expect(LinkScout::run('http://200.com', pattern: /abc/i)).to eq(true)
      end
      it 'fails if not matched' do
        expect(LinkScout::run('http://200.com', pattern: /cde/i)).to eq(false)
      end
    end

    context ':antipattern' do
      it 'fails if matched' do
        expect(LinkScout::run('http://200.com', antipattern: /abc/i)).to eq(false)
      end
      it 'succeeds if not matched' do
        expect(LinkScout::run('http://200.com', antipattern: /cde/i)).to eq(true)
      end
    end
  end

  context 'Single URLs' do
    it 'succeeds with defaults' do
      expect(LinkScout::run('http://200.com')).to eq(true)
    end
    it 'succeeds with option :url' do
      expect(LinkScout::run(url: 'http://200.com')).to eq(true)
    end
  end

  context 'Multiple with shared options' do
    it 'returns an array of [url, bool]' do
      expect(LinkScout::run(
        [
          'http://200.com',
          'http://301.com',
          'http://500.com',
          'http://deep.com?p=abc'
        ]
      )).to eq(
        [
          ['http://200.com', true],
          ['http://301.com', true],
          ['http://500.com', false],
          ['http://deep.com?p=abc', true]
        ]
      )
    end
  end

  context 'Multiple URLs with individual options' do
    it 'returns an array of [url, bool]' do
      expect(LinkScout::run([
          { url: 'http://200.com' },
          { url: 'http://500.com', success: 500 },
          { url: 'http://301.com', success: 500 },
          { url: 'http://deep.com?p=http://200.com', deeplink_param: 'p' },
          { url: 'http://deep.com?p=http%3A%2F%2F500.com', deeplink_param: 'p' }
      ])).to eq(
        [
          ['http://200.com', true],
          ['http://500.com', true],
          ['http://301.com', false],
          ['http://deep.com?p=http://200.com', true],
          ['http://deep.com?p=http%3A%2F%2F500.com', false]
        ]
      )
    end
  end
end


