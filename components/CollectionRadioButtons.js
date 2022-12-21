import * as React from 'react'

export default ({includeHidden = true, collection=[], ...rest}) => {
  if (collection.length == 0) {
    return null;
  }

  const checkboxes = collection.map((options) => {
    const { id } = options;
    const {label, ...inputOptions} = options;

    return (
      <>
        <input {...inputOptions} type="radio" />
        <label for={id}>{label}</label>
      </>
    )
  });

  const {name} = collection[0]

  return (
    <>
      {includeHidden && <input type="hidden" name={name} defaultValue={""} autocomplete="off" />}
      {checkboxes}
    </>
  )
}

