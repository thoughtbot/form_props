import * as React from 'react'

export default ({includeHidden = true, collection=[], ...rest}) => {
  if (collection.length == 0) {
    return null;
  }

  const checkboxes = collection.map((options) => {
    const { id } = options;
    const {uncheckedValue, label, ...inputOptions} = options;

    return (
      <>
        <input type="checkbox" {...inputOptions} />
        <label for={id}>{label}</label>
      </>
    )
  });

  const {name} = collection[0]

  return (
    <>
      {includeHidden && <input type="hidden" name={name} defaultValue={""} autoComplete="off" />}
      {checkboxes}
    </>
  )
}

