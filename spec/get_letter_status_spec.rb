require File.dirname(__FILE__) + '/spec_helper.rb'

describe "Get Letter Status" do

  let(:client) { PostalMethods::Client.new(PM_OPTS) }

  #before do
    #VCR.use_cassette("get_letter_status/prepare") do
    #end
  #end

  it "should send a letter and get status" do
    doc = open(File.dirname(__FILE__) + '/../spec/doc/sample.pdf')
    rv = nil
    VCR.use_cassette("get_letter_status/prepare") do
      client.prepare!

      VCR.use_cassette("get_letter_status/send_letter") do
        rv = client.send_letter(doc, "the long goodbye")
        sleep 30

        VCR.use_cassette("get_letter_status/get_letter_status") do
          f = client.get_letter_status(rv)
          puts "f = #{f.inspect}"
          f.length.should == 2
          f.first.to_i.should == -1002
        end
      end
    end
  end

  it "should send multiple letters and get their status" do
    letters = []
    1.upto(3) do |i|
      VCR.use_cassette("get_letter_status_multiple/#{i}/prepare") do
        client.prepare!
      end

      VCR.use_cassette("get_letter_status_multiple/#{i}/send_letter") do
        doc = open(File.dirname(__FILE__) + '/../spec/doc/sample.pdf')
        rv = client.send_letter(doc, "the long goodbye")
        rv.should > 0
        letters << rv
      end
    end

    VCR.use_cassette("get_letter_status_multiple/get_letter_status_multiple") do
      ret = client.get_letter_status_multiple(letters)
      ret.should be_an_instance_of(Array)

      # the return is an array [results, status]
      recv_letters = ret.collect { |r| r.iD.to_i }

      recv_letters.should == letters
    end
  end

  it "should attempt to request a multiple array of invalid letters" do
    VCR.use_cassette("get_letter_status_multiple/get_letter_status_multiple_invalid_letters") do
      lambda { client.get_letter_status_multiple([1,2,3]) }.should raise_error(PostalMethods::APIStatusCode3115Exception)
    end
  end

  it "should request a range of letters and get their status" do
    letters = []
    1.upto(3) do |i|
      VCR.use_cassette("get_letter_status_range/#{i}/prepare") do
        client.prepare!
      end
      VCR.use_cassette("get_letter_status_range/#{i}/send_letter") do
        doc = open(File.dirname(__FILE__) + '/../spec/doc/sample.pdf')
        rv = client.send_letter(doc, "the long goodbye")
        rv.should > 0
        letters << rv
      end
    end

    VCR.use_cassette("get_letter_status_range/get_letter_status_range") do
      ret = client.get_letter_status_range(letters.first, letters.last)
      ret.should be_an_instance_of(Array)

      # the return is an array [results, status]
      recv_letters = ret.collect { |r| r.iD.to_i }

      recv_letters.should == letters
    end
  end

  xit "should attempt to request a range of invalid letters" do
    VCR.use_cassette("get_letter_status_range/get_letter_status_range_invalid_letters") do
      lambda { client.get_letter_status_range(1,3) }.should raise_error(PostalMethods::APIStatusCode3115Exception)
    end
  end
end
