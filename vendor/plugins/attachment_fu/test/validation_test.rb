require File.expand_path(File.join(File.dirname(__FILE__), 'test_helper'))

class ValidationTest < Test::Unit::TestCase
  def test_should_invalidate_big_files
    @attachment = SmallAttachment.new
    assert !@attachment.valid?
    assert @attachment.errors[:size]
    
    @attachment.size = 2000
    assert !@attachment.valid?
    assert @attachment.errors[:size], @attachment.errors.full_messages.to_sentence
    
    @attachment.size = 1000
    assert !@attachment.valid?
    assert @attachment.errors[:size].empty?
  end

  def test_should_invalidate_small_files
    @attachment = BigAttachment.new
    assert !@attachment.valid?
    assert @attachment.errors[:size]
    
    @attachment.size = 2000
    assert !@attachment.valid?
    assert @attachment.errors[:size], @attachment.errors.full_messages.to_sentence
    
    @attachment.size = 1.megabyte
    assert !@attachment.valid?
    assert @attachment.errors[:size].empty?
  end
  
  def test_should_validate_content_type
    @attachment = PdfAttachment.new
    assert !@attachment.valid?
    assert @attachment.errors[:content_type]

    @attachment.content_type = 'foo'
    assert !@attachment.valid?
    assert @attachment.errors[:content_type]

    @attachment.content_type = 'pdf'
    assert !@attachment.valid?
    assert @attachment.errors[:content_type].empty?
  end

  def test_should_require_filename
    @attachment = Attachment.new
    assert !@attachment.valid?
    assert @attachment.errors[:filename]
    
    @attachment.filename = 'foo'
    assert !@attachment.valid?
    assert @attachment.errors[:filename].empty?
  end
end