<script>
    import gridData from "../data/colorPalette.json";
  
    const numRows = 5;
    const numColumns = 5;
  
    const gridColors = gridData.map(c => c.color);
  </script>
  
  <div class="cellwrapper">
    {#each Array(numRows * numColumns) as _, index}
      <div class="cell" style="background-color: {gridColors[index]}"></div>
    {/each}
  </div>
  
  <style>
    .cell {
        display: inline-block;
        width: 20%;
        height: 20vh;
    }
  
    .cellwrapper {
    position: fixed;
    top: 0;
    left: 0;
    right: 0;
    display: flex;
    flex-wrap: wrap;
    margin: 0;
    white-space: nowrap;
    width: 100%
  }
  </style>
  