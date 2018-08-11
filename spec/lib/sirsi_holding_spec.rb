require 'sirsi_holding'

RSpec.describe SirsiHolding do
  let(:field) { double('MarcField') }
  subject(:holding) { described_class.new(field) }

  describe SirsiHolding::CallNumber do
    describe '#dewey?' do
      it { expect(described_class.new('012.12 .W123')).to be_dewey }
      it { expect(described_class.new('12.12 .W123')).to be_dewey }
      it { expect(described_class.new('2.12 .W123')).to be_dewey }
      it { expect(described_class.new('PS123.34 .M123')).not_to be_dewey }
    end

    describe '#valid_lc?' do
      it { expect(described_class.new('K123.34 .M123')).to be_valid_lc }
      it { expect(described_class.new('KF123.34 .M123')).to be_valid_lc }
      it { expect(described_class.new('KFC123.34 .M123')).to be_valid_lc }
      it { expect(described_class.new('012.12 .W123')).not_to be_valid_lc }
    end

    describe '#before_cutter' do
      it 'is correct hwen the cutter has a leading perioud' do
        expect(described_class.new('012.12 .W123').before_cutter).to eq '012.12'
        expect(described_class.new('012.12.W123').before_cutter).to eq '012.12'
      end

      it 'is correct hwen the cutter does not have a leading period' do
        expect(described_class.new('012.12 W123').before_cutter).to eq '012.12'
      end

      it 'is correct when the cutter has a leading slash' do
        expect(described_class.new('012.12/W123').before_cutter).to eq '012.12'
      end
    end

    describe '#with_leading_zeros' do
      it 'adds the correct leading zeros as needed' do
        expect(described_class.new('002.12 .W123').with_leading_zeros).to eq '002.12 .W123'
        expect(described_class.new('02.12 .W123').with_leading_zeros).to eq  '002.12 .W123'
        expect(described_class.new('2.12 .W123').with_leading_zeros).to eq   '002.12 .W123'
        expect(described_class.new('62 .B862 V.193').with_leading_zeros).to eq '062 .B862 V.193'
      end
    end

    describe 'lopped_callnumber' do
      context 'with an LC call number' do
        {
          'Z7164 .S67 M54 MFILM REEL 42' => 'Z7164 .S67 M54',
          'Q1 .N2 V.434:NO.7031 2005:MAR.17' => 'Q1 .N2',
          'Q1 .N2 V.421-426 2003:INDEX' => 'Q1 .N2',
          'Q1 .N2 V.171 1953:JAN.-MAR.' => 'Q1 .N2',
          'Z286 .D47 J69 1992:MAR.-DEC.' => 'Z286 .D47 J69 1992',
          'QD1 .C59 1973:P.1-1252' => 'QD1 .C59 1973',
          'Q1 .S34 V.209:4452-4460 1980:JUL.-AUG.' => 'Q1 .S34',
          'Q1 .S34 V.293-294:5536-5543 2001:SEP-OCT' => 'Q1 .S34',
          'ML1 .I614 INDEX 1969-1986' => 'ML1 .I614',
          'KD270 .E64 INDEX:A/K' => 'KD270 .E64',
          'M270 .I854 1999' => 'M270 .I854 1999',
          'TX519 .D26S 1954 V.2' => 'TX519 .D26S 1954',
          'QD1 .C59 1975:V.1-742' => 'QD1 .C59 1975'
        }.each do |call_number, expected|
          describe "with #{call_number}" do
            let(:holding) { SirsiHolding.new(call_number: call_number, scheme: 'LC') }
            specify do
              expect(holding.lopped_callnumber(false)).to eq expected
            end
          end
        end

        {
          'Z7164 .S67 M54 MFILM REEL 42' => 'Z7164 .S67 M54',
          'Q1 .N2 V.434:NO.7031 2005:MAR.17' => 'Q1 .N2',
          'Q1 .N2 V.421-426 2003:INDEX' => 'Q1 .N2',
          'Q1 .N2 V.171 1953:JAN.-MAR.' => 'Q1 .N2',
          'Z286 .D47 J69 1992:MAR.-DEC.' => 'Z286 .D47 J69',
          'QD1 .C59 1973:P.1-1252' => 'QD1 .C59',
          'Q1 .S34 V.209:4452-4460 1980:JUL.-AUG.' => 'Q1 .S34',
          'Q1 .S34 V.293-294:5536-5543 2001:SEP-OCT' => 'Q1 .S34',
          'ML1 .I614 INDEX 1969-1986' => 'ML1 .I614',
          'KD270 .E64 INDEX:A/K' => 'KD270 .E64',
          'M270 .I854 1999' => 'M270 .I854',
          'TX519 .D26S 1954 V.2' => 'TX519 .D26S',
          'QD1 .C59 1975:V.1-742' => 'QD1 .C59'
        }.each do |call_number, expected|
          describe "with #{call_number}, but a serial" do
            let(:holding) { SirsiHolding.new(call_number: call_number, scheme: 'LC') }
            specify do
              expect(holding.lopped_callnumber(true)).to eq expected
            end
          end
        end
      end
    end
  end
end
