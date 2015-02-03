require 'test_helper.rb'
set_path(__FILE__)

require 'ip_address_registrar'
require 'fileutils'

describe IpAddressRegistrar do

  context "default region (GI)" do
    around do |example|
      FileUtils.cp("#{spec_root_path}/test_source/test.db.dev.jp", "#{spec_root_path}/test_source/test.db.dev.jp.bak")
      FileUtils.cp("#{spec_root_path}/test_source/test.db.10", "#{spec_root_path}/test_source/test.db.10.bak")
      example.run
      FileUtils.mv("#{spec_root_path}/test_source/test.db.dev.jp.bak", "#{spec_root_path}/test_source/test.db.dev.jp", {:force => true})
      FileUtils.mv("#{spec_root_path}/test_source/test.db.10.bak", "#{spec_root_path}/test_source/test.db.10", {:force => true})
    end

    let(:reg) {
      reg = IpAddressRegistrar.new
      reg.stub(:git_push)
      reg.stub(:git_pull)
      reg.stub(:git_clone)
      reg.stub(:zone_file_path).and_return("#{spec_root_path}/test_source/test.db.dev.jp")
      reg.stub(:ptr_zone_file_path).and_return("#{spec_root_path}/test_source/test.db.10")
      reg
    }

    describe "#checks_hostname" do
      context "with blank hostname ''" do
        it { expect{reg.check_hostname('')}.to raise_error(RuntimeError) }
      end
      context "with used hostname 'jenkins'" do
        it { expect{reg.check_hostname('jenkins')}.to raise_error(RuntimeError) }
      end
      context "with used hostname 'nymul-eeee'" do
        it { expect{reg.check_hostname('nymul-eeee')}.to raise_error(RuntimeError) }
      end
      context "with used hostname 'cayzac01'" do
        it { expect{reg.check_hostname('cayzac01')}.to raise_error(RuntimeError) }
      end
      context "with unused hostname 'qazwsxedcrfv54321'" do
        it { reg.check_hostname('qazwsxedcrfv54321').should be_true }
      end
      context "with hostname 'qa#xev541' include invalid charactor(s)" do
        it { expect{reg.check_hostname('qa#xev541')}.to raise_error(RuntimeError) }
      end
      context "with hostname 'qaz&21-hg' include invalid charactor(s)" do
        it { expect{reg.check_hostname('qaz&21-hg')}.to raise_error(RuntimeError) }
      end
      context "with hostname 'abc_efg' include invalid charactor(s)" do
        it { expect{reg.check_hostname('abc_efg')}.to raise_error(RuntimeError) }
      end
      context "with hostname 'sub.qazwsxedcrfv543210' include (subdomain)" do
        it { expect{reg.check_hostname('sub.qazwsxedcrfv543210')}.to raise_error(RuntimeError) }
      end
    end

    describe "#hostname_exist" do
      context "with blank hostname ''" do
        it { reg.hostname_exist?('').should be_false }
      end

      context "with existing hostname 'jenkins'" do
        it { reg.hostname_exist?('jenkins').should be_true }
      end

      context "with existing hostname 'jenkins'" do
        it { reg.hostname_exist?('jenkins', reg.ptr_zone_file_path).should be_true }
      end

      context "with non-existing hostname 'qazwsxedcrfv54321'" do
        it { reg.hostname_exist?('qazwsxedcrfv54321').should be_false }
      end
    end

    describe "#get_record" do
      context "with blank hostname ''" do
        it { expect(reg.get_record('')).to be_nil }
      end

      context "with existing hostname 'xiaofei-bao-php5' and dont search CNAME record" do
        it { expect(reg.get_record('xiaofei-bao-php5')).to include(:a_record)}
        it { expect(reg.get_record('xiaofei-bao-php5')).to include(:ptr_record)}
        it { expect(reg.get_record('xiaofei-bao-php5')).not_to include(:cname_record)}
      end

      context "with existing hostname 'xiaofei-bao-php5' and search CNAME record" do
        it { expect(reg.get_record('xiaofei-bao-php5', true)).to include(:cname_record)}
      end

      context "with non-existing hostname 'qazwsxedcrfv54321'" do
        it { expect(reg.get_record('qazwsxedcrfv54321')).to be_empty }
      end
    end

    describe "#remove_record" do
      context "with not existed hostname 'xev541'" do
        it "return exception with not existed hostname 'xev541'" do
          expect{reg.remove_record('xev541')}.to raise_error(RuntimeError)
        end
      end

      context "with blank hostname ''" do
        it { expect{reg.remove_record('')}.to raise_error(RuntimeError) }
      end

      context "with existed hostname 'xiaofei-bao-php5' and  remove_cname=false" do
        before do
          reg.remove_record('xiaofei-bao-php5')
        end
        it "num of removed A record in zone_file is 0" do
          `diff #{reg.zone_file_path} #{reg.zone_file_path}.bak | grep -w A | grep xiaofei-bao-php5 | wc -l`.chomp.should eq '1'
        end
        it "num of removed record in ptr_zone_file is 0" do
          `diff #{reg.ptr_zone_file_path} #{reg.ptr_zone_file_path}.bak | grep -w PTR | grep xiaofei-bao-php5 | wc -l`.chomp.should eq '1'
        end
      end

      context "with existed hostname 'xiaofei-bao-php5' and remove_cname=true" do
        before do
          reg.remove_record('xiaofei-bao-php5',true)
        end
        it "num of CNAME record in zone_file is 0" do
          `diff #{reg.zone_file_path} #{reg.zone_file_path}.bak | grep -E '\b(CNAME|MX)\b' | grep xiaofei-bao-php5 | wc -l`.chomp.should_not eq 0
        end
      end
    end

    describe "#auto_ip_register" do
      context "with host_name 'my_hostname'" do
        before do
          @ip = reg.auto_ip_register('my-hostname')
        end
        it 'ip address is valid' do
          @ip.should match /^((?:25[0-5]|2[0-4]\d|[01]?\d?\d)\.){3}(?:25[0-5]|2[0-4]\d|[01]?\d?\d)$/
        end
        it 'num of registered ip in zone_file is 1' do
          `diff #{reg.zone_file_path} #{reg.zone_file_path}.bak | grep #{@ip} | grep -w A | wc -l`.chomp.should eq '1'
        end
      end

      context "when the pre pool is full" do
        before do
          reg.stub(:zone_file_path).and_return("#{spec_root_path}/test_source/test.db.dev.jp_e")
        end
        it 'raise RuntimeError' do
          expect{reg.auto_ip_register('my-hostname')}.to raise_error(RuntimeError)
        end
      end
    end

    describe "#auto_ptr_register" do
      context "with ip '10.0.0.1' hostname 'ptrtest'" do
        before do
          @ip = '10.0.0.1'
          reg.auto_ptr_register(@ip,'ptrtest')
        end
        it 'num of registered ptr record is 1' do
          `diff #{reg.ptr_zone_file_path} #{reg.ptr_zone_file_path}.bak | grep #{@ip.split('.').reverse[0..2].join('.')} | grep -w PTR | wc -l`.chomp.should eq '1'
        end
      end
    end
  end

  context "gkr region" do
    let(:reg) {
      reg = IpAddressRegistrar.new
      reg.region = 'gkr'
      reg.stub(:git_push)
      reg.stub(:git_pull)
      reg.stub(:git_clone)
      reg.stub(:zone_file_path).and_return("#{spec_root_path}/test_source/test.db.kr.**-dev.net")
      reg.stub(:ptr_zone_file_path).and_return("#{spec_root_path}/test_source/test.db.10")
      reg
    }

    describe "checks hostname is already used or not," do
      it "return exception because gkr-dev01 is in use" do
        expect{reg.check_hostname('gkr-dev01')}.to raise_error(RuntimeError)
      end
      it "return true because chef-eval is not in use on gcn" do
        reg.check_hostname('chef-eval').should be_true
      end
    end
  end
end
