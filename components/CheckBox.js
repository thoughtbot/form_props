import * as React from 'react'

export default ({includeHidden = true, name=null, uncheckedValue=null, children, ...rest}) => {
  return (
    <>
      {includeHidden && <input type="hidden" name={name} defaultValue={uncheckedValue} autoComplete="off" />}
      <input type="checkbox" name={name} {...rest}>
        {children}
      </input>
    </>
  )
}

