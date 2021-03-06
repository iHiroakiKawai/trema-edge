#
# Author: Nick Karanatsios <nickkaranatsios@gmail.com>
#
# Copyright (C) 2008-2013 NEC Corporation
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License, version 2, as
# published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
#

require File.join(File.dirname(__FILE__), '..', 'spec_helper')
require 'trema'

shared_examples_for 'any OpenFlow message with tp_src option' do
  it_should_behave_like 'any OpenFlow message', option: :tp_src, name: 'Source TCP or UDP port', size: 16
end

describe ActionSetTpSrc, '.new( VALID OPTION )' do
  subject { ActionSetTpSrc.new(tp_src: tp_src) }
  let(:tp_src) { 5555 }

  describe '#tp_src' do
    subject { super().tp_src }
    it { is_expected.to eq(5555) }
  end
  it 'should inspect its attributes' do
    expect(subject.inspect).to eq('#<Trema::ActionSetTpSrc tp_port=5555>')
  end
  it_should_behave_like 'any OpenFlow message with tp_src option'
end

describe ActionSetTpSrc, '.new( MANDATORY OPTION MISSING )' do
  it 'should raise ArgumentError' do
    expect { subject }.to raise_error(ArgumentError)
  end
end

describe ActionSetTpSrc, '.new( INVALID OPTION ) - argument type Array instead of Hash' do
  subject { ActionSetTpSrc.new([5555]) }
  it 'should raise TypeError' do
    expect { subject }.to raise_error(TypeError)
  end
end

describe ActionSetTpSrc, '.new( VALID OPTION )' do
  context 'when sending #flow_mod(add) with action set to mod_tp_src' do
    it 'should respond to #append' do
      class FlowModAddController < Controller; end
      network do
        vswitch { datapath_id 0xabc }
      end.run(FlowModAddController) do
        action = ActionSetTpSrc.new(tp_src: 5555)
        expect(action).to receive(:append)
        controller('FlowModAddController').send_flow_mod_add(0xabc, actions: action)
      end
    end

    it 'should have a flow with action set to mod_tp_src' do
      class FlowModAddController < Controller; end
      network do
        vswitch { datapath_id 0xabc }
      end.run(FlowModAddController) do
        controller('FlowModAddController').send_flow_mod_add(0xabc, actions: ActionSetTpSrc.new(tp_src: 5555))
        expect(vswitch('0xabc').size).to eq(1)
        expect(vswitch('0xabc').flows[0].actions).to match(/mod_tp_src:5555/)
      end
    end
  end
end

### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
