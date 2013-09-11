require 'words'


class TestClass
  include Words
end
 
describe Words do
  subject do
   TestClass.new
  end

  it 'should get words group by alp' do
     groups = subject.get_words_group_by_alp ['WOOD', 'GOOD', 'TEST']
     groups.keys.should include('W','O','D','G','T','E','S')
     groups['W'].should include('WOOD')
     groups['O'].should include('WOOD','GOOD')
     groups['D'].should include('GOOD')
     groups['T'].should include('TEST')
     groups['E'].should include('TEST')
  end

  it 'should get letters order by word frequency' do
    letters = subject.get_letters_order_by_word_frequency({'W'=>['WOOD'], 'O'=>['WOOD','GOOD'], 'D'=>['WOOD','GOOD','FLOD']})
    letters[0].should == 'D'
    letters[1].should == 'O'
    letters[2].should == 'W'
  end
end
