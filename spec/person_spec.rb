require 'spec_helper'

describe Person do

  it { should validate_presence_of :name }

  context '#spouse' do
    it 'returns the spouse' do
      earl = Person.create(:name => 'Earl')
      steve = Person.create(:name => 'Steve')
      steve.update(:spouse_id => earl.id)
      expect(steve.spouse).to eq earl
    end

    it "is nil if they aren't married" do
      earl = Person.create(:name => 'Earl')
      expect(earl.spouse).to eq nil
    end
  end

  context '#parent' do
    it 'returns the parents if they are also in the database' do
      steve_jr = Person.create(:name=>'Steve Jr')
      mary = Person.create(:name=>'Mary')
      steve_sr = Person.create(:name=>'Steve Sr')
      steve_jr.update(:parent1_id=>steve_sr.id, :parent2_id=>mary.id)
      expect(steve_jr.parents).to eq [steve_sr, mary]
    end

    it 'returns one parent if only one parent is in the database' do
      cindy = Person.create(:name=>'Cindy')
      karalee = Person.create(:name=>'Karalee')
      cindy.update(:parent1_id=>karalee.id)
      expect(cindy.parents).to eq [karalee]
    end

    it 'returns no parents if no parents are in the database' do
      cindy = Person.create(:name=>'Cindy')
      expect(cindy.parents).to eq []
    end
  end

  it "updates the spouse's id when its spouse_id is changed" do
    earl = Person.create(:name => 'Earl')
    steve = Person.create(:name => 'Steve')
    steve.update(:spouse_id => earl.id)
    earl.reload
    earl.spouse_id.should eq steve.id
  end

end
