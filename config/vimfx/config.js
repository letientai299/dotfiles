let {commands} = vimfx.modes.normal
// Zoom
vimfx.addCommand({
  name: 'zoom_in',
  description: 'Zoom in',
}, ({vim}) => {
  vim.window.FullZoom.enlarge()
})


vimfx.addCommand({
  name: 'zoom_out',
  description: 'Zoom out',
}, ({vim}) => {
  vim.window.FullZoom.reduce()
})


// Search bookmarks
vimfx.addCommand({
  name: 'search_bookmarks',
  description: 'Search bookmarks',
  category: 'location',
  order: commands.focus_location_bar.order + 1,
}, (args) => {
  commands.focus_location_bar.run(args)
  args.vim.window.gURLBar.value = '* '
})


// Open some 'about:' sites
vimfx.addCommand({
  name: 'goto_downloads',
  description: 'Downloads',
}, ({vim}) => {
  vim.window.gBrowser.loadOneTab('about:downloads')
})

// Move tab to index
// This command moves the current tab before tab number count.
vimfx.addCommand({
  name: 'tab_move_to_index',
  description: 'Move tab to index',
  category: 'tabs',
  order: commands.tab_move_forward.order + 1,
}, ({vim, count}) => {
  if (count === undefined) {
    vim.notify('Provide a count')
    return
  }
  let {window} = vim
  window.setTimeout(() => {
    let {selectedTab} = window.gBrowser
    if (selectedTab.pinned) {
      vim.notify('Run from a non-pinned tab')
      return
    }
    let newPosition = window.gBrowser._numPinnedTabs + count - 1
    window.gBrowser.moveTabTo(selectedTab, newPosition)
  }, 0)
})

// Close tab to the left
vimfx.addCommand({
  name: 'tab_close_to_start',
  description: 'Close tabs to the left',
  category: 'tabs',
  order: commands.tab_close_to_end.order + 1,
}, ({vim}) => {
  let {gBrowser} = vim.window
  Array.slice(gBrowser.tabs, gBrowser._numPinnedTabs, gBrowser.selectedTab._tPos)
    .forEach(tab => gBrowser.removeTab(tab))
})

