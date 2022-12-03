message CallArgumentSizeMismatch do
  title "Type Error"

  block do
    text "The function you called takes"
    bold size
    text "arguments, while you tried to call it with"
    bold call_size
    text "the function type is"
    bold type
  end

  snippet node, "You tried to call it here:"
end
