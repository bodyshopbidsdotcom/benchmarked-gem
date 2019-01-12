class TestClass
  def public_benchmarked(arg1, arg2)
    'Return from public_benchmarked'
  end
  handle_with_benchmark :public_benchmarked

  def public_that_yields(arg1)
    ret = ''

    3.times do |t|
      ret += t.to_s + yield(arg1)
    end

    ret
  end
  handle_with_benchmark :public_that_yields

  def public_that_yields_with_block_param(arg1, &block)
    ret = ''

    3.times do |t|
      ret += t.to_s + yield(arg1)
    end

    ret
  end
  handle_with_benchmark :public_that_yields_with_block_param

  private

  def private_benchmarked(arg1, arg2)
    'Return from private_benchmarked'
  end
  handle_with_benchmark :private_benchmarked

  def private_that_yields(arg1)
    ret = ''

    3.times do |t|
      ret += t.to_s + yield(arg1)
    end

    ret
  end
  handle_with_benchmark :private_that_yields
end

class TestNotifier
  def self.benchmark_taken(measurement, obj, method_name, args, result)
  end
end

RSpec.describe Benchmarked do
  it 'has a version number' do
    expect(Benchmarked::VERSION).not_to be nil
  end

  describe '#config' do
    let(:test_class_instance) { TestClass.new }

    before(:each) do
      Benchmarked.configure do |config|
        config.notifier = TestNotifier
      end
    end

    describe '#clean_configuration' do
      it 'resets all the config variables' do
        Benchmarked.clean_configuration
        expect(Benchmarked.instance_variable_get('@notifier')).to be_nil
      end
    end

    it 'calls benchmark_taken' do
      expect(TestNotifier).to receive(:benchmark_taken).with(anything, test_class_instance, :public_benchmarked, ['arg1', 'arg2'], 'Return from public_benchmarked')
      expect(test_class_instance.public_benchmarked('arg1', 'arg2')).to eq('Return from public_benchmarked')
    end

    it 'does not crash if the notifier is nil' do
      Benchmarked.clean_configuration
      expect(TestNotifier).to_not receive(:benchmark_taken)
      expect(test_class_instance.public_benchmarked('arg1', 'arg2')).to eq('Return from public_benchmarked')
    end

    context 'given we call private_benchmarked' do
      it 'calls benchmark_taken by calling with send' do
        expect(TestNotifier).to receive(:benchmark_taken).with(anything, test_class_instance, :private_benchmarked, ['arg1', 'arg2'], 'Return from private_benchmarked')
        expect(test_class_instance.send(:private_benchmarked, 'arg1', 'arg2')).to eq('Return from private_benchmarked')
      end

      it 'calls benchmark_taken by calling with send on private_benchmarked_with_benchmark' do
        expect(TestNotifier).to receive(:benchmark_taken).with(anything, test_class_instance, :private_benchmarked, ['arg1', 'arg2'], 'Return from private_benchmarked')
        expect(test_class_instance.send(:private_benchmarked_with_benchmark, 'arg1', 'arg2')).to eq('Return from private_benchmarked')
      end

      it 'does not call benchmark_taken by calling with send on private_benchmarked_without_benchmark' do
        expect(TestNotifier).to_not receive(:benchmark_taken)
        expect(test_class_instance.send(:private_benchmarked_without_benchmark, 'arg1', 'arg2')).to eq('Return from private_benchmarked')
      end

      it 'raises private method error on calling private_benchmarked directly' do
        error_raised = false

        begin
          test_class_instance.private_benchmarked
        rescue NoMethodError => exception
          expect(exception.message).to start_with('private method `private_benchmarked\' called for')
          error_raised = true
        end

        expect(error_raised).to be(true)
      end

      it 'raises private method error on calling private_benchmarked_with_benchmark directly' do
        error_raised = false

        begin
          test_class_instance.private_benchmarked_with_benchmark
        rescue NoMethodError => exception
          expect(exception.message).to start_with('private method `private_benchmarked_with_benchmark\' called for')
          error_raised = true
        end

        expect(error_raised).to be(true)
      end

      it 'raises private method error on calling private_benchmarked_without_benchmark directly' do
        error_raised = false

        begin
          test_class_instance.private_benchmarked_without_benchmark
        rescue NoMethodError => exception
          expect(exception.message).to start_with('private method `private_benchmarked_without_benchmark\' called for')
          error_raised = true
        end

        expect(error_raised).to be(true)
      end
    end

    context 'given we call public_that_yields' do
      it 'works as expected when passed a block' do
        expect(TestNotifier).to receive(:benchmark_taken).once.with(anything, test_class_instance, :public_that_yields, ['something'], '0something|1something|2something|')

        result = test_class_instance.public_that_yields('something') do |arg|
          "#{arg}|"
        end

        expect(result).to eq('0something|1something|2something|')
      end

      it 'works as expected when called multiple times' do
        expect(TestNotifier).to receive(:benchmark_taken).once.with(anything, test_class_instance, :public_that_yields, ['something'], '0something|1something|2something|')
        expect(TestNotifier).to receive(:benchmark_taken).once.with(anything, test_class_instance, :public_that_yields, ['other'], '0other|1other|2other|')

        result = test_class_instance.public_that_yields('something') do |arg|
          "#{arg}|"
        end

        expect(result).to eq('0something|1something|2something|')

        result = test_class_instance.public_that_yields('other') do |arg|
          "#{arg}|"
        end

        expect(result).to eq('0other|1other|2other|')
      end

      it 'works as expected when passed a proc with as block' do
        expect(TestNotifier).to receive(:benchmark_taken).once.with(anything, test_class_instance, :public_that_yields, ['something'], '0something|1something|2something|')

        a_proc = Proc.new { |arg| "#{arg}|" }
        result = test_class_instance.public_that_yields('something', &a_proc)

        expect(result).to eq('0something|1something|2something|')
      end
    end

    context 'given we call public_that_yields_with_block_param' do
      it 'works as expected when passed a block' do
        expect(TestNotifier).to receive(:benchmark_taken).once.with(anything, test_class_instance, :public_that_yields_with_block_param, ['something'], '0something|1something|2something|')

        result = test_class_instance.public_that_yields_with_block_param('something') do |arg|
          "#{arg}|"
        end

        expect(result).to eq('0something|1something|2something|')
      end

      it 'works as expected when passed a proc' do
        expect(TestNotifier).to receive(:benchmark_taken).once.with(anything, test_class_instance, :public_that_yields_with_block_param, ['something'], '0something|1something|2something|')

        a_proc = Proc.new { |arg| "#{arg}|" }
        result = test_class_instance.public_that_yields_with_block_param('something', &a_proc)

        expect(result).to eq('0something|1something|2something|')
      end

      it 'raises an error when not passed a block' do
        expect(TestNotifier).to_not receive(:benchmark_taken)
        expect { test_class_instance.public_that_yields_with_block_param('something') }.to raise_error(LocalJumpError)
      end
    end

    context 'given we call private_that_yields' do
      it 'works as expected' do
        expect(TestNotifier).to receive(:benchmark_taken).once.with(anything, test_class_instance, :private_that_yields, ['something'], '0something|1something|2something|')

        result = test_class_instance.send(:private_that_yields, 'something') do |arg|
          "#{arg}|"
        end

        expect(result).to eq('0something|1something|2something|')
      end
    end
  end
end
