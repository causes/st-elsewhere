# These tests are insanely incomplete.  Testing a module like this without
# depending on an encompasing Rails application is quite difficult.  These
# tests use mocks on the objects under test, which feels almost useless.
# I may consider publishing an accompanyhing Rails application with a test
# suite that tests this module in a usable state.

require 'test_helper'
require 'st-elsewhere'

class Doctor < Struct.new :id, :name
end

class HospitalDoctor < Struct.new :id, :doctor_id, :hospital_id
  attr_accessor :doctor, :hospital
end

class HospitalDean < Struct.new :id, :dean_id, :hospital_id
  attr_accessor :dean, :hospital
end

class Hospital < Struct.new :id, :name
  extend StElsewhere
  has_many_elsewhere :doctors, :through => :hospital_doctors
  has_many_elsewhere :deans,   :through => :hospital_deans, :class_name => 'Doctor'
end

class StElsewhereTest < Test::Unit::TestCase

  def setup
    @hospital = Hospital.new
    @hospital.id = 1
    @hospital.name = "St. Elsewhere"

    @doctor  = Doctor.new
    @doctor.id = 1
    @doctor.name = "Dr. Foo"

    @doctor2 = Doctor.new
    @doctor2.id = 2
    @doctor2.name = "Dr. Bar"

    @dean = Doctor.new
    @dean.id = 3
    @dean.name = "Lida Cuddy"

    @hospital_doctor  = HospitalDoctor.new
    @hospital_doctor.id = 1
    @hospital_doctor.doctor_id = @doctor.id
    @hospital_doctor.hospital_id = @hospital.id

    @hospital_doctor2 = HospitalDoctor.new
    @hospital_doctor2.id = 2
    @hospital_doctor2.doctor_id = @doctor2.id
    @hospital_doctor2.hospital_id = @hospital.id

    @hospital_dean = HospitalDean.new
    @hospital_dean.id = 1
    @hospital_dean.dean_id = @dean.id
    @hospital_dean.hospital_id = @hospital.id
  end

  def test_basic_obj_setup
    assert "St. Elsewhere".eql?(@hospital.name)
    assert @hospital.respond_to? :doctors
    assert @hospital.respond_to? :doctors=
    assert @hospital.respond_to? :doctor_ids
    assert @hospital.respond_to? :doctor_ids=
  end

  def test_basic_functionality
    mock(@hospital_doctor).doctor {@doctor}
    mock(@hospital_doctor2).doctor {@doctor2}
    mock(HospitalDoctor).find([1,2]) {[@hospital_doctor, @hospital_doctor2]}
    mock(@hospital).hospital_doctor_ids {[@hospital_doctor.id, @hospital_doctor2.id]}

    assert @hospital.doctors.eql?([@doctor, @doctor2])
  end

  def test_manual_class_name
    assert @hospital.respond_to? :deans
    assert @hospital.respond_to? :deans=
    assert @hospital.respond_to? :dean_ids
    assert @hospital.respond_to? :dean_ids=

    mock(@hospital_dean).dean {@dean}
    mock(HospitalDean).find([1]) {[@hospital_dean]}
    mock(@hospital).hospital_dean_ids {[@hospital_dean.id]}

    assert @hospital.deans.eql?([@dean])
  end

end
