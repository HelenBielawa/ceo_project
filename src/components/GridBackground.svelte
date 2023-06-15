<script>
  import gridData from "../data/colorPalette.json";
  import Tooltip from "./Tooltip.svelte";
  
    const numRows = 5;
    const numColumns = 5;
    let clickedCluster;
    let hoveredCluster;
    const gridColors = gridData.map(c => c.color);

</script>
  

  <div class="cellwrapper">
    {#each Array(numRows * numColumns) as _, index}
      <div class="cell"
      style="background-color: {gridColors[index]};
             opacity: {hoveredCluster == index? 0.5 : 1}"
      on:mouseover={() => hoveredCluster = index}
      on:focus={() => hoveredCluster = index}
      on:click={() => clickedCluster = index}
      on:keydown={(event) => {
        if (event.key === 'Enter') {
          clickedCluster = index;
        }
      }}>
    {#if clickedCluster == index} 
      {gridData.find(g => g.groupID == index).cluster}
    {/if}
    </div>
    {/each}
  </div>

  <style>
    .cell {
        display: inline-block;
        width: 20%;
        height: 20vh;
        z-index: 10;
    }
  
    .cellwrapper {
    position: inherit;
    display: flex;
    flex-wrap: wrap;
    white-space: nowrap;
    width: 100%;
    z-index: 90;
  }

  </style>
  