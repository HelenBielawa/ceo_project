<script>
    import gridData from "../data/colorPalette.json";
    $: width = 500;
    $: height = 500;

    const numRows = 5;
    const numColumns = 5;
  
    $: cellSize = width/numColumns; // Adjust the size of each grid cell as needed
    $: gridSize = cellSize * numColumns; // Total size of the grid
  
    const gridColors = gridData.map(c => c.color)
  </script>
  
 
  <div class="grid-container"
    bind:clientWidth={width}
    bind:clientHeight={height}>
    {#each Array(numRows * numColumns) as _, index}
      <div class="grid-cell" style="background-color: {gridColors[index % gridColors.length]}"></div>
    {/each}
  </div>
  

  <style>
  .grid-container {
        width: 100vw; /* Full width of the viewport */
        height: 100vh; /* Full height of the viewport */
        display: grid;
        grid-template-columns: repeat(${numColumns}, ${cellSize}px);
        grid-template-rows: repeat(${numRows}, ${cellSize}px);
        gap: 1px; /* Gap between grid cells */
    }
  
    .grid-cell {
        display: flex;
        align-items: center;
        justify-content: center;
        background-color: white;
    }
  </style>