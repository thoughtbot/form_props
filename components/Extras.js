import * as React from 'react'

export default (hiddenInputAttributes) => {
  const hiddenProps = Object.values(hiddenInputAttributes);
  const hiddenInputs = hiddenProps.map((props) => (
    <input {...props} type="hidden"/>
  ));

  return (
    <>{hiddenInputs}</>
  )
}
