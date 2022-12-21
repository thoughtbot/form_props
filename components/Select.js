import * as React from 'react'

export default ({includeHidden= true, name=null, id=null, children, options=[], multiple=false, disabled=false, type=null, ...rest}) => {
  const addHidden = includeHidden && multiple

  const optionElements = options.map((option) => {
    if (option.hasOwnProperty('options')) {
      return (
        <optgroup label={option.label} key={option.label}>
          {option.options.map((opt) => <option key={opt.label} {...opt}/>)}
        </optgroup>
      )
    } else {
      return <option key={option.label} {...option}/>
    }
  });

  return (
    <>
      {addHidden && <input type="hidden" disabled={disabled} name={name} value={""} autocomplete="off" />}
      <select name={name} id={id} multiple={multiple} disabled={disabled} {...rest}>
        {children}
        {optionElements}
      </select>
    </>
  )
}
