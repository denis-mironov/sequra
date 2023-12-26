# frozen_string_literal: true

shared_examples 'doesn\'t create merchant' do
  it { expect { execute_task }.not_to change(Merchant, :count) }
end

shared_examples 'doesn\'t create order' do
  it { expect { execute_task }.not_to change(Order, :count) }
end

shared_examples 'outputs start and finish messages' do
  it { expect { execute_task }.to output(start_message).to_stdout }
  it { expect { execute_task }.to output(finish_message).to_stdout }
end

shared_examples 'outputs start message, finish message and error messages' do
  it { expect { execute_task }.to output(start_message).to_stdout }
  it { expect { execute_task }.to output(error_message).to_stdout }
  it { expect { execute_task }.to output(validation_error_message).to_stdout }
  it { expect { execute_task }.to output(finish_message).to_stdout }
end
