require File.expand_path '../test_setup', __FILE__

class MyTest < MiniTest::Unit::TestCase
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_home_redirect
    get '/'
    assert_equal "http://example.org/", last_request.url
    assert last_response.ok?
    refute last_response.body.include?(" operators at LDS on #{Date.today.strftime('%Y-%m-%d')}")
    assert last_response.body.include?('All data from <a href="http://www.realtimetrains.co.uk/">Realtime Trains</a>')
  end

  def test_lds_with_date
    get '/LDS?date=2015-08-29'
    assert last_response.ok?
    assert last_response.body.include?(" operators at Leeds on 2015-08-29")
    assert last_response.body.include?('All data from <a href="http://www.realtimetrains.co.uk/">Realtime Trains</a>')
    assert last_response.body.include?('/to/York')
    assert last_response.body.include?('/from/Liverpool')
  end

  def test_platform_filter
    get '/LDS/platform/1?date=2015-08-29'
    follow_redirect!
    assert last_response.ok?
    assert last_response.body.include?("platform 1")
    refute last_response.body.include?("realtimetrains.co.uk/train")
    assert last_response.body.include?('All data from <a href="http://www.realtimetrains.co.uk/">Realtime Trains</a>')

    get '/LDS/platform/8?date=2015-08-29'
    follow_redirect!
    assert last_response.ok?
    assert last_response.body.include?("platform 8")
    assert last_response.body.include?("realtimetrains.co.uk/train/Y00244")
    refute last_response.body.include?('Y00118')
    assert last_response.body.include?('All data from <a href="http://www.realtimetrains.co.uk/">Realtime Trains</a>')
  end

  def test_toc_filter
    get '/LDS/operator/EM?date=2015-08-29'
    follow_redirect!
    assert last_response.ok?
    assert last_response.body.include?("EM")
    refute last_response.body.include?("realtimetrains.co.uk/train")
    assert last_response.body.include?('All data from <a href="http://www.realtimetrains.co.uk/">Realtime Trains</a>')
  end

  def test_service_filter
    get '/LDS/type/train?date=2015-08-29'
    follow_redirect!
    assert last_response.ok?
    assert last_response.body.include?("train")
    assert last_response.body.include?("realtimetrains.co.uk/train/Y00244")
  end

  def test_origin_filter
    get '/LDS/from/Ilkley?date=2015-08-29'
    follow_redirect!
    assert last_response.ok?
    assert last_response.body.include?('Ilkley')
    refute last_response.body.include?('realtimetrains.co.uk/train')
    assert last_response.body.include?('All data from <a href="http://www.realtimetrains.co.uk/">Realtime Trains</a>')

    get '/LDS/from/Liverpool%20Lime%20Street?date=2015-08-29'
    follow_redirect!
    assert last_response.ok?
    assert last_response.body.include?('Liverpool Lime Street')
    assert last_response.body.include?('realtimetrains.co.uk/train/Y00244')
    refute last_response.body.include?('Y00118')
    assert last_response.body.include?('All data from <a href="http://www.realtimetrains.co.uk/">Realtime Trains</a>')
  end

  def test_destination_filter
    get '/LDS/to/Ilkley?date=2015-08-29'
    follow_redirect!
    assert last_response.ok?
    assert last_response.body.include?('Ilkley')
    refute last_response.body.include?('realtimetrains.co.uk/train')
    assert last_response.body.include?('All data from <a href="http://www.realtimetrains.co.uk/">Realtime Trains</a>')

    get '/LDS/to/York?date=2015-08-29'
    follow_redirect!
    assert last_response.ok?
    assert last_response.body.include?('York')
    assert last_response.body.include?('realtimetrains.co.uk/train/Y00244')
    assert last_response.body.include?('realtimetrains.co.uk/train/Y00118')
    assert last_response.body.include?('All data from <a href="http://www.realtimetrains.co.uk/">Realtime Trains</a>')
  end

  def test_cached_data
    get '/cached'
    assert last_response.ok?
    assert last_response.body.include?('LDS-arrivals-2015-08-29.json')
  end

  def test_unique
    get '/LDS/unique?date=2015-08-29'
    assert last_response.ok?
    assert last_response.body.include?("new operators at Leeds on 2015-08-29")
    assert last_response.body.include?('All data from <a href="http://www.realtimetrains.co.uk/">Realtime Trains</a>')
    assert last_response.body.include?('/to/York')
    assert last_response.body.include?('/from/Liverpool')
  end
end