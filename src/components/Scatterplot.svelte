<script>
    import AxisX from "./AxisX.svelte";
    import AxisY from "./AxisY.svelte";
    import Tooltip from "./Tooltip.svelte";
    import stepContent from "../data/stepContent.json";
    import socioClusterData from "../data/clusters_socioeconomic.json";
    import politicalClusterData from "../data/politicalClusters.json";
    import individualsData from "../data/pred_individuals_social.json";
    import {extent} from "d3-array";
    import { fly } from "svelte/transition";
    import { scaleLinear } from "d3-scale";
    import {Compass} from "svelte-bootstrap-icons";
    import {onMount} from "svelte";

    export let currentStep;
    export let data;
    export let currentStatus;

    let hoveredData;
    let groupViz = false;

    $: currentStepContent = stepContent[currentStep];
   
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
        .domain(extent(data.filter(d => d.NUM > 0), d => +d.NUM))
        .range([10, innerWidth/15])
  
    const loadGroupJSON = (cluster) => {
    const url = "./src/data/testData_group"+ cluster + ".json";
    return fetch(url)
      .then(response => response.json())
      .catch(error => console.error(error));
    };

    function handleCircleClick(cluster) {
      groupViz = ! groupViz;
      if (groupViz){
        console.log("click "+cluster)
        let grData = individualsData[String(cluster)]
                    .map(obj => ({
                        ...obj,
                        ["Cluster"]: cluster,
                      }));
        currentStatus = "groupViz";
        console.log(currentStatus)
        console.log(grData)

      }
      else{
        currentStatus = "sociodemViz";
        data = socioClusterData;
      }

    }

    function getTransitionParams(d){
      console.log("d: ", d);

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
          {#each data.sort((a, b) => a.RIGHT_PRED - b.RIGHT_PRED) as d, index}
            <!-- svelte-ignore a11y-no-noninteractive-tabindex -->
                          <!-- transition:fly={currentStatus == "groupViz" ? { x: -100, opacity: 50, duration: 500 }
                      : {...getTransitionParams(d)}} -->
            <circle 

              cx={xScale(d.RIGHT_PRED)}
              cy={yScale(d.INDEP_PRED)}
              fill={d.NUM === 0 ? "red": "black"}
              r={d.NUM === 0 ? innerWidth/20 : radiusScale(d.NUM)}
              opacity={hoveredData ?
                        currentStatus === "politicalViz"?
                        d.RIGHT_PRED === hoveredData.RIGHT_Pred_Mean ? 1 : 0.45
                        : 0.6 : 0.6}
              on:mouseover={() => currentStatus === "sociodemViz"? hoveredData = socioClusterData.find(sd => sd.INDEP_Pred_Mean === d.INDEP_PRED)
                            : hoveredData = politicalClusterData.find(pd => pd["INDEP.QUANT_Pred_Mean"] === d.INDEP_PRED)}
              on:focus={() => currentStatus === "sociodemViz"? hoveredData = socioClusterData[index]
                            : hoveredData = politicalClusterData[index]}
              on:click={() => handleCircleClick(d.Cluster)}
              on:keydown={(event) => {
                if (event.key === 'Enter') {
                  handleCircleClick(d.Cluster);
                }
              }}
              tabindex="0"
            />
          {/each}
        {#if groupViz}
          {#each grData as d, index}
            <!-- svelte-ignore a11y-no-noninteractive-tabindex -->
            <circle 
              in:fly={{...getTransitionParams(d)}}
              cx={xScale(d.RIGHT)}
              cy={yScale(d.INDEP)}
              fill="black"
              stroke="none"
              r = 4
              opacity = 1
            />
          {/each}
        {/if}
      </g>
    </svg>
    {#if hoveredData}
      <Tooltip {xScale} {yScale} {width} {height} data={hoveredData} {currentStatus} />
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
  