transition { 'run twice':
  resource   => Notify['message'],
  attributes => { message => 'This content should display before' },
  prior_to   => Notify['ending'],
}

notify { 'message':
  message => 'This content should display after'
}

notify { 'ending':
  message => 'The end'
}
