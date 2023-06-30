<script>
    import AxisX from "./AxisX.svelte";
    import AxisY from "./AxisY.svelte";
    import AxisCompass from "./AxisXCompass.svelte";
    import Tooltip from "./Tooltip.svelte";
    import stepContent from "../data/stepContent.json";
    import politicalClusterData from "../data/politicalClusters.json";
    import individualsData from "../data/pred_individuals_social.json";
    import socioTooltipData from "../data/clusters_socioeconomic.json";
    import {extent} from "d3-array";
    import { fly } from "svelte/transition";
    import { scaleLinear } from "d3-scale";
    import {Compass} from "svelte-bootstrap-icons";
    import {onMount} from "svelte";

    export let currentStep;
    export let data;
    export let currentStatus;
    export let socioClusterData;

    $: console.log("in the scatter, data: ", data)

let hoveredData;

$: {
  if(currentStatus === "top-left"){
    hoveredData = politicalClusterData.find(pd => pd.Political_Cluster === 10)
  }
  else{
    hoveredData = false;
  }
}

    $: groupViz = false;
  
    $: width = 100;
    $: height = 800;

    $: grData  = [];

    const margin = { top:0, right: 0, bottom: 0, left: 0 };
 
    $: innerWidth = width - margin.left - margin.right;
    $: innerHeight = height - margin.top - margin.bottom;
  
    $: xScale = scaleLinear()
      .domain([0, 100])
      .range([0, innerWidth]);
  
    $: yScale = scaleLinear()
      .domain([0, 100])
      .range([innerHeight, 0]);

    $: radiusScale = scaleLinear()
        .domain(extent(data.filter(d => d.Perc_Users > 0), d => +d.Perc_Users))
        .range([10, innerWidth/15]);
 
    const loadGroupJSON = (cluster) => {
    const url = "./src/data/testData_group"+ cluster + ".json";
    return fetch(url)
      .then(response => response.json())
      .catch(error => console.error(error));
    };

    function handleCircleClick(cluster) {

      groupViz = !groupViz;
      if (groupViz){
        console.log("click "+cluster)
        grData = individualsData[String(cluster)]
                    .filter( d => 0.25 >= Math.random())
                    .map(obj => ({
                        ...obj,
                        ["Cluster"]: cluster,
                      }))
        currentStatus = "groupViz";
        //console.table(grData)

      }
      else{
        currentStatus = "sociodemViz";
        console.log("in click function, went back to sociodem viz")
        data = socioClusterData;
      }

    }

    function getTransitionParams(d){

      let destinationX = xScale(d.RIGHT);
      let destinationY = yScale(d.INDEP);

      let parentEl = socioClusterData.find(s => s.Cluster === parseInt(d.Cluster))

      let originX = xScale(parentEl.RIGHT_Pred_Mean);
      let originY = yScale(parentEl.INDEP_Pred_Mean);

      const deltaX = -destinationX + originX;
      const deltaY = -destinationY + originY;

      return {
        x: deltaX,
        y: deltaY,
        duration: 1000
      };
    }

  </script>

  <div
    class="chart-container"
    bind:clientWidth={width}
    bind:clientHeight={height}>
  
    <svg {width} {height}
    on:mouseleave={() => hoveredData = null}>

      <g class="inner-chart" transform="translate({margin.left}, {margin.top})">
        <AxisY width={innerWidth} {yScale} {xScale}/>
        <AxisX height={innerHeight} width={innerWidth} {xScale} {yScale} />
        


          {#if !groupViz}
          {#each data.sort((a, b) => a.RIGHT_PRED - b.RIGHT_PRED) as d, index}

            <!-- svelte-ignore a11y-no-noninteractive-tabindex -->
            <circle 
              cx={xScale(d.RIGHT_PRED)}
              cy={yScale(d.INDEP_PRED)}
              fill={d.Perc_Users === 0 ? "transparent":
                    d.Twin? "transparent" : "black"}
              r={d.Perc_Users === 0 ? innerWidth/20 : radiusScale(d.Perc_Users)}
              opacity={ currentStatus === "top-left" && d.Cluster === 10? 1
                        : hoveredData ?
                          currentStatus === "politicalViz"?
                          d.RIGHT_PRED === hoveredData.RIGHT_Pred_Mean ?
                          1 :
                        0.45
                        : 0.3 : 0.6}
              stroke={d.Perc_Users === 0 || d.Twin ? "black": "transparent"}
              stroke-width={5}
              on:mouseover={() => currentStatus === "sociodemViz"?
                                    hoveredData = socioTooltipData.find(sd => sd.Cluster === d.Cluster)
                                  : hoveredData = politicalClusterData.find(pd => pd["INDEP.QUANT_Pred_Mean"] === d.INDEP_PRED)}
              on:focus={() => currentStatus === "sociodemViz"? hoveredData = socioTooltipData.find(sd => sd.Cluster === d.Cluster)
                            : hoveredData = politicalClusterData.find(pd => pd["INDEP.QUANT_Pred_Mean"] === d.INDEP_PRED)}
              on:click={() => handleCircleClick(d.Cluster)}
              on:keydown={(event) => {
                if (event.key === 'Enter') {
                  handleCircleClick(d.Cluster);
                }
              }}
              tabindex="0"
            />
          {/each}
        {/if}
        {#if groupViz}
          {#each grData as d, i}
            <!-- svelte-ignore a11y-no-noninteractive-tabindex
             -->
            <circle 
            in:fly={{...getTransitionParams(d)}}
              cx={xScale(d.RIGHT)}
              cy={yScale(d.INDEP)}
              fill="black"
              stroke="none"
              r = "4"
              opacity = "0.5"
              on:mouseover={() => hoveredData = d}
              on:focus={() => hoveredData = d}
              on:click={() => handleCircleClick(1)}
              on:keydown={(event) => {
                if (event.key === 'Enter') {
                  handleCircleClick(1);
                }
              }}
            />
          {/each}
        {/if}
      </g>
    </svg>
    {#if hoveredData}
      <Tooltip {xScale} {yScale} {width} {height} data={hoveredData} {currentStatus}
        xVar = {currentStatus === "politicalViz" || currentStatus === "top-left" ? "RIGHT.QUANT_Pred_Mean" : "RIGHT_Pred_Mean"}
        yVar = {currentStatus === "politicalViz" || currentStatus === "top-left" ? "INDEP.QUANT_Pred_Mean" : "INDEP_Pred_Mean"} />
    {/if}
  </div>
  
  <style>
  

   .chart-container{
   position: inherit;
    display: flex;
    flex-wrap: wrap;
    white-space: nowrap;
    width: 100%;
    height: 100%;
    z-index: 100;
    background: none;
    pointer-events: none;
   }
    circle {
      /*transition: r 300ms ease, opacity 500ms ease;*/
      cursor: pointer;
      pointer-events: all;
      z-index: 9999;
    }
    button{
      z-index: 9999;
      position: fixed;
    }
    .compass {
    animation: spin 3s linear infinite;
    fill: #000;
    width: 24px;
    height: 24px;
    transform-style: preserve-3d;
    left: 50%;
    bottom: 50%;
    position: absolute;
    transform-origin: center center;
  }
  </style>
  