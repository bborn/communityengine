class PagingEnumerator
  
  #PF returns a paging enumerator object, which doesn't have a .first method, so we'll add it here.
  def first
    self.to_a.first
  end

end

PaginatingFind::Helpers::DEFAULT_OPTIONS[:link_to_current_page] = true
