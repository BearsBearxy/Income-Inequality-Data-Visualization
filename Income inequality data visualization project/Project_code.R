#import library
install.packages("rnaturalearthdata")
library(shiny)
library(plotly)
library(dplyr)
library(readr)
library(scales)

# ---------- Import ----------

# degree level
degree_order  <- c("less_bachelor","bachelor","bachelor_plus","graduate")
degree_labels <- c(
  less_bachelor = "Less than bachelor's",
  bachelor      = "Bachelor's degree",
  bachelor_plus = "Bachelor's degree or higher",
  graduate      = "Graduate degree"
)

#background picture
BG_IMAGE  <- "background.png"
BG2_IMAGE <- "background.png"
addResourcePath("local", ".")

BG_SRC  <- if (file.exists(file.path("www", BG_IMAGE)))  BG_IMAGE  else file.path("local", BG_IMAGE)
BG2_SRC <- if (file.exists(file.path("www", BG2_IMAGE))) BG2_IMAGE else file.path("local", BG2_IMAGE)



# ---------- Page 6 data ----------
race_order  <- c("asian","black","hispanic","white")
race_labels <- c(asian="Asian", black="Black", hispanic="Hispanic", white="White")

OCC_FOUR <- c(
  "accountants and auditors",
  "actors",
  "actuaries",
  "acupuncturists"
)

C_fixed <- readr::read_csv("C_fixed.csv", show_col_types = FALSE) |> 
  dplyr::mutate(
    degree = factor(degree, levels = degree_order),
    race   = factor(tolower(race), levels = race_order)
  )
OCC_ALL <- sort(unique(C_fixed$occupation))


# ---------------------------------- CSS -----------------------------------
css_tpl <- "
html, body { height:100%; margin:0; padding:0; overflow:hidden; font-family:'DM Sans', system-ui, -apple-system, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif; color:#fff; }
#snap-container { height:100vh; width:100vw; overflow-y:scroll; overflow-x:hidden; scroll-snap-type:y mandatory; scroll-behavior:smooth; -webkit-overflow-scrolling:touch; }

/* scroll down animation */
.snap-section { 
  height:100vh; width:100vw; scroll-snap-align:start; scroll-snap-stop:always; 
  display:flex; align-items:center; justify-content:center; overflow:hidden; 
  opacity: 0;
  transform: translateY(30px);
  transition: all 0.8s cubic-bezier(0.25, 0.46, 0.45, 0.94);
}
.snap-section.active { 
  opacity: 1;
  transform: translateY(0);
}


/* ---------- font---------- */
.text-description {
  font-size: 30px;
  line-height: 2;
  color: #fff;
  margin-bottom: 15px;
  font-family: 'DM Sans', system-ui, -apple-system, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
}

.text-highlight {
  font-size: 18px;
  font-weight: 700;
  display: inline;
}


.text-large {
  font-size: 40px;
}

.text-extra-bold {
  font-weight: 1000;
}

.text-italic {
  font-style: italic;
}



/* ----------------------first page------------------------ */
.hero { position:relative; padding:0; background:#000; }
.hero-content { position:absolute; inset:0; display:flex; flex-direction:column; align-items:center; justify-content:center; gap:24px; text-align:center; padding:0 6vw; }
.hero-title { 
  font-weight:200; text-transform:uppercase; letter-spacing:.02em; font-size:clamp(30px,4vw,70px); line-height:.95; color:#fff; margin:0; 
  opacity: 0;
  transform: translateY(20px);
  animation: fadeInUp 0.8s ease 0.2s forwards;
}
.hero-cta { 
  position:absolute; left:50%; bottom:6vh; transform:translateX(-50%); z-index:2; display:inline-flex; align-items:center; justify-content:center; padding:14px 28px; border-radius:9999px; border:1px solid rgba(0,0,0,.12); background:linear-gradient(180deg, rgba(255,255,255,.85), rgba(245,249,255,.75)); backdrop-filter:blur(6px); font-weight:500; letter-spacing:.06em; text-transform:uppercase; font-size:clamp(14px,1.6vw,18px); color:#111; text-decoration:none; cursor:pointer; box-shadow:0 8px 24px rgba(0,0,0,.08); 
  opacity: 0;
  transform: translateY(20px);
  animation: fadeInUp 0.8s ease 0.5s forwards;
}
.hero-cta:hover { box-shadow:0 10px 30px rgba(0,0,0,.12); transform:translateX(-50%) translateY(-1px); }

@keyframes fadeInUp {
  to {
    opacity: 1;
    transform: translateY(0);
  }
}


.snap-section:not(.hero){
  background-image:url('REPLACE_BG2');
  background-size:cover; background-position:center; background-repeat:no-repeat;
}


.section-fit{ height:100%; width:100%; display:flex; flex-direction:column; min-height:0; }


.row-vh{
  height:100%;
  display:grid;
  grid-template-columns:2fr 1fr;
  column-gap:12px;
  padding:0;
  box-sizing:border-box;
  align-items:stretch;
  overflow:hidden;
}
.row-vh .left{ grid-column:1; display:flex; flex-direction:column; min-height:0; min-width:0; }
.row-vh .chart{ flex:1; min-height:0; display:flex; align-items:stretch; justify-content:stretch; }
.row-vh .right{ grid-column:2; min-width:0; display:flex; flex-direction:column; gap:16px; max-height:100%; overflow-y:auto; overflow-x:hidden; }


/* ------------------------ page 1.5------------- ---------- */
.question-page {
  position: relative;

  scroll-snap-align: start;
  height: 100vh;
  width: 100vw;
  display: flex;
  align-items: center;
  justify-content: center;
  overflow: hidden;
}

.question-container {
  position: relative;
  height: 100%;
  width: 100%;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  padding: 0 10vw;
  text-align: center;
}

.main-question {
  font-size: clamp(28px, 4vw, 48px);
  font-weight: 300;
  line-height: 1.3;
  color: #fff;
  margin-bottom: 60px;
  opacity: 1;
  transform: translateY(0);
  transition: all 0.8s ease;
  font-family: 'DM Sans', system-ui, -apple-system, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
}

.main-question.hidden {
  opacity: 0;
  transform: translateY(-30px);
}

.sub-questions {
  display: flex;
  flex-direction: column;
  gap: 30px;
  margin-bottom: 80px;
}

.sub-question {
  font-size: clamp(18px, 2.5vw, 28px);
  font-weight: 400;
  line-height: 1.4;
  color: rgba(255, 255, 255, 1);
  opacity: 0;
  transform: translateY(20px);
  transition: all 0.6s ease;
  padding: 20px 40px;
  border-radius: 20px;
  background: rgba(255, 255, 255, 0.05);
  backdrop-filter: blur(10px);
  border: 1px solid rgba(255, 255, 255, 0.1);
  font-family: 'DM Sans', system-ui, -apple-system, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
}

.sub-question.active {
  opacity: 1;
  transform: translateY(0);
}

/*arrow-button */
.arrow-button {
  position: absolute;
  bottom: 40px;
  left: 50%;
  transform: translateX(-50%);
  background: transparent;
  border: none;
  display: flex;
  flex-direction: column;
  align-items: center;
  cursor: pointer;
  transition: all 0.3s ease;
  gap: 10px;
}


.sub-question.active {
  opacity: 1 !important;
  transform: translateY(0) !important;
}


.arrow-button {
  cursor: pointer;
  pointer-events: auto;
  z-index: 100;
}


.question-container {
  position: relative;
  z-index: 10;
}

.arrow-button:hover {
  transform: translateX(-50%) translateY(-5px);
}

.arrow-text {
  color: rgba(255, 255, 255, 1);
  font-size: 30px;
  font-family: 'DM Sans', system-ui, -apple-system, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
  margin-bottom: 5px;
}

.arrow-icon {
  width: 24px;
  height: 24px;
  border-right: 3px solid rgba(255, 255, 255, 1);
  border-bottom: 3px solid rgba(255, 255, 255, 1);
  transform: rotate(45deg);
  transition: all 0.3s ease;
}

.arrow-button:hover .arrow-icon {
  border-color: rgba(255, 255, 255, 1);
  transform: rotate(45deg) translateY(5px);
}

.continue-text {
  margin-top: 60px;
  font-size: 20px;
  color: rgba(255, 255, 255, 1);
  opacity: 0;
  transition: opacity 0.5s ease;
  font-family: 'DM Sans', system-ui, -apple-system, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
}

.continue-text.show {
  opacity: 1;
}




/* -------------------page 2------------------------- */
.side-card{
  background:#fff;
  padding:14px 16px;
  border-radius:16px;
  box-shadow:0 12px 28px rgba(20,35,80,.12);
  width:100%;
  color:#2b2f36;
  box-sizing:border-box;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  transform: translateY(0);
}
.side-card:hover {
  transform: translateY(-5px);
  box-shadow:0 20px 40px rgba(20,35,80,0.15);
}


.side-card--flush{
  padding:16px 24px;
}


.row-vh .left .side-card--flush{
  margin:12px 18px;
}

/* Capsule button */
.seg{ 
  position:relative; display:inline-flex; gap:6px; padding:6px;
  background:#fff; border-radius:9999px; box-shadow:0 10px 25px rgba(30,50,120,.12); 
}
.seg-btn{ 
  position:relative; z-index:1; border:0; background:transparent;
  height:36px; line-height:36px; padding:0 18px; border-radius:9999px;
  font-weight:600; font-size:14px; cursor:pointer; white-space:nowrap;
  color:#7a7f87 !important;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  position: relative;
  overflow: hidden;
}
.seg-btn::before {
  content: '';
  position: absolute;
  top: 0;
  left: -100%;
  width: 100%;
  height: 100%;
  background: linear-gradient(90deg, transparent, rgba(255,255,255,0.2), transparent);
  transition: left 0.5s;
}
.seg-btn:hover::before {
  left: 100%;
}
.seg-btn.active{ color:#fff !important; }
.seg-glider{ 
  position:absolute; z-index:0; top:6px; height:36px; left:6px;
  border-radius:9999px; background-image:linear-gradient(135deg,#63e6fb,#7b7bff);
  box-shadow:0 6px 20px rgba(123,123,255,.35);
  transition:transform .22s ease, width .22s ease; 
}
            

#p_dist, #p_dist .html-widget, #p_dist .plotly, #p_dist .plot-container, #p_dist .main-svg{ height:100% !important; width:100% !important; }

.row-vh .left, .row-vh .right{ min-width:0; }


.seg-btn{
  color: #7a7f87 !important;
  font-size: 14px;
  -webkit-appearance: none;
  appearance: none;
}
.seg-btn.active{ color: #fff !important; }


.row-vh .right{
  overflow-x: hidden;
  padding-right: 0;
}
.side-card{
  max-width: 100%;
  box-sizing: border-box;
}
.side-card .html-widget,
.side-card .plotly,
.side-card .plot-container,
.side-card .main-svg{
  width: 100% !important; 
}


.side-card, .side-card *{
  color: #2b2f36;
}

/* Degree Tabs */
.deg-tabs-wrap{ margin-top:50px; position:sticky; bottom:50px; z-index:3; display:flex; justify-content:center; }


.sex-tabs-wrap{ display:flex; justify-content:flex-start; }


#sex-seg .seg-btn,
#deg-seg .seg-btn{
  height:36px; line-height:36px; padding:0 18px;
  border-radius:9999px; font-weight:600; font-size:14px;
  -webkit-appearance:none; appearance:none;
}


#sex-seg.seg{
  background:#fff; border-radius:9999px;
  box-shadow:0 10px 25px rgba(30,50,120,.12);
  gap:6px; padding:6px;
}


#sex-seg .seg-btn{
  color:#7a7f87 !important;
  background:transparent;
  transition:background .22s ease, color .22s ease, box-shadow .22s ease;
}


#sex-seg .seg-btn.active{
  color:#fff !important;
  background-image:linear-gradient(135deg,#63e6fb,#7b7bff);
  box-shadow:0 6px 20px rgba(123,123,255,.35);
}

/* page 2 font */
.page2-description {
  margin-top: 20px;
  font-size: 16px;
  line-height: 1.6;
  color: #fff;
}

.page2-description p {
  margin-bottom: 15px;
}

.highlight-blue {
  font-size: 18px;
  font-weight: 700;
  color: #63e6fb;
}

.highlight-pink {
  font-size: 18px;
  font-weight: 700;
  color: #ff6b6b;
}

/* gap-percentage number */
#gap-percentage-big {
  font-size: 32px;
  font-weight: 700;
  color: #fff;
  text-align: right;
  text-shadow: 0 2px 8px rgba(0,0,0,0.3);
  margin-right: 100px;
  margin-top: 10px;
  transition: all 0.3s ease;
  animation: pulse 2s infinite;
}

@keyframes pulse {
  0% { transform: scale(1); }
  50% { transform: scale(1.05); }
  100% { transform: scale(1); }
}

#p_md_wrap .html-widget,
#p_md_wrap .plotly,
#p_md_wrap .plot-container,
#p_md_wrap .main-svg { height:100% !important; width:100% !important; }

/* ---------------------------------page3------------------------------- */
#page-3 .main-question {
  margin-bottom: 80px;
}

#page-3 .sub-questions {
  margin-bottom: 120px;
}

#page-3 .sub-question {
  font-size: clamp(16px, 2.2vw, 24px);
  max-width: 800px;
  margin: 0 auto;
}


/* --------------------- Page 4 map plot-------------------- */

#map-wrap { 
  position: relative; 
  width: 100%; 
  height: 100%; 
}

.map-card { 
  border-radius: 20px;
  overflow: hidden;
  margin: 8vh 0 4vh 4vh;
  box-shadow: 0 20px 40px rgba(20,35,80,.15);
  transition: all 0.4s cubic-bezier(0.25, 0.46, 0.45, 0.94);
  background: white;
  width: 90%;
  height: 68vh;
}

.map-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 25px 50px rgba(20,35,80,.2);
}

.map-controls {
  position: absolute;
  left: 0;
  right: 0;
  bottom: -5px;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 20px;
  padding: 15px 25px;
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(10px);
  border-radius: 16px;
  box-shadow: 0 8px 25px rgba(0,0,0,0.1);
  border: 1px solid rgba(0,0,0,0.05);
  z-index: 3;
  pointer-events: auto;
  flex-wrap: wrap;
}


.custom-play-container {
  order: -1;
}

.custom-play-btn {
  background: linear-gradient(135deg, #4ECDC4, #44A08D);
  border: none;
  border-radius: 20px;
  color: white;
  padding: 8px 16px;
  font-size: 13px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
  box-shadow: 0 4px 12px rgba(78, 205, 196, 0.3);
  font-family: 'DM Sans', sans-serif;
}

.custom-play-btn:hover {
  background: linear-gradient(135deg, #44A08D, #4ECDC4);
  transform: translateY(-2px);
  box-shadow: 0 6px 18px rgba(78, 205, 196, 0.4);
}

.custom-play-btn:active {
  transform: translateY(0);
}

/* slider style */
.map-controls .shiny-input-container {
  margin-bottom: 0;
  flex-grow: 1;
  max-width: 320px;
  min-width: 250px;
}


.map-controls .irs--shiny .irs-bar {
  background: linear-gradient(135deg, #667eea, #764ba2);
  border: none;
  height: 6px;
}

.map-controls .irs--shiny .irs-line {
  background: #e0e0e0;
  border: none;
  height: 6px;
}

.map-controls .irs--shiny .irs-handle {
  border: 4px solid #667eea;
  background: #fff;
  box-shadow: 0 3px 10px rgba(102, 126, 234, 0.3);
  transition: all 0.3s ease;
  width: 18px;
  height: 18px;
  top: 20px;
}

.map-controls .irs--shiny .irs-handle:hover {
  transform: scale(1.2);
  box-shadow: 0 5px 15px rgba(102, 126, 234, 0.4);
}

.map-controls .irs--shiny .irs-from,
.map-controls .irs--shiny .irs-to,
.map-controls .irs--shiny .irs-single {
  background: #667eea;
  color: white;
}

/* map plot style */
.map-legend { 
  display: flex;
  align-items: center;
  gap: 8px;
  color: #2b2f36;
  font-weight: 600;
  font-size: 11px;
  flex-shrink: 0;
  flex-direction: column;
}

.map-legend-container {
  display: flex;
  align-items: center;
  gap: 8px;
}

.map-legend-labels {
  display: flex;
  justify-content: space-between;
  width: 100%;
  margin-top: 4px;
  font-size: 10px;
  color: #2b2f36;
  font-weight: 600;
}

.map-legend .swatches { 
  display: flex;
  height: 16px;
  border-radius: 8px;
  overflow: hidden;
  box-shadow: 0 2px 8px rgba(0,0,0,.15);
  width: 300px;
}

.map-legend .sw { 
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 9px;
  color: rgba(255,255,255,0.9);
  text-shadow: 0 1px 2px rgba(0,0,0,0.3);
  font-weight: 700;
  transition: all 0.3s ease;
  position: relative;
  min-width: 0;
}

/* map legend colour */
.sw.c0{ background:#f7d6e6; }
.sw.c1{ background:#e8b3d3; }
.sw.c2{ background:#d38ec1; }
.sw.c3{ background:#b86aae; }
.sw.c4{ background:#923f97; }
.sw.c5{ background:#701d7a; }

/* map legend highlight */
.map-legend .sw.highlighted {
  transform: scale(1.1);
  box-shadow: 0 0 0 2px #4ECDC4, 0 4px 12px rgba(78, 205, 196, 0.5);
  z-index: 10;
  border-radius: 4px;
}

/* 无数据样式 */
.map-legend .nodata{
  width: 48px;
  height: 16px;
  border-radius: 8px;
  overflow: hidden;
  background: repeating-linear-gradient(-45deg, #e9e9e9 0 6px, #ffffff 6px 12px);
  border: 1px solid #ddd;
  box-shadow: 0 2px 8px rgba(0,0,0,0.1);
}

.map-tips {
  background: rgba(102, 126, 234, 0.1);
  border-radius: 12px;
  padding: 16px;
  border: 1px solid rgba(102, 126, 234, 0.3);
  margin: 20px 0 0 4vh;
  max-width: 90%;
}

#map-wrap .plotly, 
#map-wrap .js-plotly-plot { 
  height: 100% !important; 
  width: 100% !important;
}


@media (max-width: 1200px) {
  .map-card {
    width: 85% !important;
  }
  
  .map-controls {
    flex-direction: column;
    gap: 15px;
    padding: 15px;
  }
  
  .map-controls .shiny-input-container {
    max-width: 100%;
  }
  
  .map-legend .swatches {
    width: 250px;
  }
}

@media (max-width: 768px) {
  .map-card {
    width: 95% !important;
    height: 60vh !important;
    margin-left: 2vh !important;
    margin-top: 5vh !important;
  }
  
  .map-controls {
    padding: 10px;
    gap: 12px;
  }
  
  .map-legend {
    flex-wrap: wrap;
    justify-content: center;
  }
  
  .map-legend .swatches {
    width: 200px;
  }
  
  .map-legend-labels {
    font-size: 8px;
  }
}


/* --------------------- Page 6  --------------------------------- */

.row-11 { 
  grid-template-columns: 1fr 1fr;
  gap: 20px; /* 增加间距改善可读性 */
}

.occ-card { 
  width: 48vw; 
  height: 72vh;
  box-shadow: 0 20px 40px rgba(20,35,80,.15);
  border-radius: 20px;
  transition: all 0.4s cubic-bezier(0.25, 0.46, 0.45, 0.94);
}

.occ-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 25px 50px rgba(20,35,80,.2);
}

.occ-dd { 
  position: relative; 
  width: min(420px, 90%); 
}

.pill-toggle {
  all: unset; 
  display: inline-flex; 
  align-items: center; 
  gap: 12px;
  padding: 12px 24px;
  border-radius: 9999px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: #fff; 
  font-weight: 700; 
  cursor: pointer;
  box-shadow: 0 8px 25px rgba(102, 126, 234, 0.3);
  transition: all 0.4s cubic-bezier(0.25, 0.46, 0.45, 0.94);
  font-family: 'DM Sans', sans-serif;
}

.pill-toggle:hover {
  transform: translateY(-3px);
  box-shadow: 0 12px 35px rgba(102, 126, 234, 0.4);
  background: linear-gradient(135deg, #764ba2 0%, #667eea 100%);
}

.pill-toggle:active {
  transform: translateY(-1px);
}

.pill-toggle .caret { 
  transition: transform 0.3s ease; 
  font-size: 12px;
}

.pill-toggle .label { 
  white-space: nowrap; 
  max-width: 270px; 
  overflow: hidden; 
  text-overflow: ellipsis;
  font-size: 15px;
}

.pill-menu {
  position: absolute; 
  top: 54px; 
  left: 0; 
  right: auto;
  background: #fff; 
  border-radius: 16px; 
  box-shadow: 0 20px 45px rgba(20,35,80,.25);
  padding: 16px; 
  width: 100%; 
  max-height: 350px; 
  overflow: auto; 
  display: none;
  opacity: 0;
  transform: translateY(-15px);
  transition: all 0.4s cubic-bezier(0.25, 0.46, 0.45, 0.94);
  z-index: 100;
  border: 1px solid rgba(0,0,0,0.05);
}

.pill-menu.open { 
  display: block;
  opacity: 1;
  transform: translateY(0);
}

.pill-item {
  padding: 12px 16px; 
  border-radius: 12px; 
  color: #2b2f36;
  font-weight: 600; 
  cursor: pointer;
  transition: all 0.3s ease;
  font-family: 'DM Sans', sans-serif;
  font-size: 14px;
  margin-bottom: 4px;
  border: 1px solid transparent;
}

.pill-item:hover { 
  background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
  color: white;
  transform: translateX(8px);
  box-shadow: 0 5px 15px rgba(245, 87, 108, 0.3);
}

.pill-item.active { 
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  box-shadow: 0 5px 15px rgba(102, 126, 234, 0.3);
}

.right {
  padding-right: 20px;
}

.right h3 {
  font-size: 24px;
  font-weight: 600;
  margin-bottom: 20px;
  color: #fff;
  text-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.right .text-description {
  font-size: 25px;
  line-height: 1.7;
  color: rgba(255,255,255,1);
  margin-bottom: 20px;
}

#deg-seg-6.seg {
  margin-top: 25px;
  box-shadow: 0 10px 25px rgba(30,50,120,.15);
}

@media (max-width: 1200px) {
  .row-11 {
    grid-template-columns: 1.2fr 0.8fr;
  }
  
  .occ-card {
    width: 55vw;
  }
}

@media (max-width: 768px) {
  .row-11 {
    grid-template-columns: 1fr;
    gap: 15px;
  }
  
  .occ-card {
    width: 90vw;
    height: 60vh;
  }
}

.control-section {
  display: flex;
  align-items: flex-start;
  gap: 25px;
  margin-bottom: 30px;
  position: relative;
}

.dropdown-container {
  flex-shrink: 0;
  position: relative;
}

.instruction-bubble {
  flex: 1;
  background: linear-gradient(135deg, rgba(102, 126, 234, 0.1), rgba(118, 75, 162, 0.1));
  border: 1px solid rgba(102, 126, 234, 0.3);
  border-radius: 16px;
  padding: 16px 20px 16px 45px;
  font-size: 14px;
  line-height: 1.5;
  color: rgba(255, 255, 255, 0.9);
  position: relative;
  backdrop-filter: blur(10px);
  box-shadow: 0 8px 25px rgba(102, 126, 234, 0.15);
  transition: all 0.3s ease;
}

.instruction-bubble:hover {
  transform: translateY(-2px);
  box-shadow: 0 12px 30px rgba(102, 126, 234, 0.2);
}

.arrow-connector {
  position: absolute;
  left: -20px;
  top: 50%;
  transform: translateY(-50%);
  width: 24px;
  height: 2px;
  background: linear-gradient(90deg, #667eea, transparent);
}

.arrow-connector::before {
  content: '';
  position: absolute;
  left: -6px;
  top: 50%;
  transform: translateY(-50%);
  width: 0;
  height: 0;
  border-top: 6px solid transparent;
  border-bottom: 6px solid transparent;
  border-right: 8px solid #667eea;
}


.loading-spinner {
  display: inline-block;
  width: 20px;
  height: 20px;
  border: 3px solid rgba(255,255,255,.3);
  border-radius: 50%;
  border-top-color: #fff;
  animation: spin 1s ease-in-out infinite;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}



/*------------------------- final page-------------------------- */
.insight-card {
  transition: all 0.3s ease;
  backdrop-filter: blur(10px);
}

.insight-card:hover {
  transform: translateY(-5px);
  background: rgba(255,255,255,0.15) !important;
  box-shadow: 0 10px 30px rgba(0,0,0,0.2);
}

@media (max-width: 768px) {
  .insight-card {
    grid-column: 1 / -1 !important;
  }
}



#data-source-modal {
  opacity: 0;
  transition: opacity 0.3s ease;
  display: none;
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0,0,0,0.8);
  z-index: 1000;
  align-items: center;
  justify-content: center;
}

#data-source-modal.modal-open {
  display: flex;
  opacity: 1;
  animation: fadeIn 0.3s ease;
}

#data-source-modal > div {
  transform: scale(0.9);
  transition: transform 0.3s ease;
}

#data-source-modal.modal-open > div {
  transform: scale(1);
  animation: zoomIn 0.3s ease;
}

@keyframes fadeIn {
  from { opacity: 0; }
  to { opacity: 1; }
}

@keyframes zoomIn {
  from { 
    transform: scale(0.9);
    opacity: 0;
  }
  to { 
    transform: scale(1);
    opacity: 1;
  }
}


#data-source-modal a {
  color: #7b7bff;
  text-decoration: none;
  transition: color 0.2s ease;
}

#data-source-modal a:hover {
  color: #63e6fb;
  text-decoration: underline;
}
"

# ---------- UI ----------
ui <- tagList(
  tags$head(
    tags$style(HTML(gsub("REPLACE_BG2", BG2_SRC, css_tpl, fixed = TRUE)))
  ),
  tags$link(href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@300;400;500;700&display=swap", rel="stylesheet"),
  
  # scroll down aninmation
  tags$script(HTML("
    document.addEventListener('DOMContentLoaded', function() {
      const sections = document.querySelectorAll('.snap-section');
      const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
          if (entry.isIntersecting) {
            entry.target.classList.add('active');
          }
        });
      }, { threshold: 0.3 });
      
      sections.forEach(section => observer.observe(section));
    });
  ")),
  
  
  # question page
  tags$script(HTML("
    document.addEventListener('DOMContentLoaded', function() {
      const mainQuestion = document.getElementById('main-question');
      const subQuestions = [
        document.getElementById('sub-question-1'),
        document.getElementById('sub-question-2'), 
        document.getElementById('sub-question-3')
      ];
      const arrowButton = document.getElementById('arrow-button');
      const continueText = document.querySelector('.continue-text');
      
      let currentStep = 0;
      const totalSteps = 4;
      let isAnimating = false;
      
      updateDisplay();
      
      function updateDisplay() {

        subQuestions.forEach(q => q.classList.remove('active'));
        if (continueText) continueText.classList.remove('show');

        switch(currentStep) {
          case 0:
            mainQuestion.classList.remove('hidden');
            break;
          case 1:
            mainQuestion.classList.add('hidden');
            subQuestions[0].classList.add('active');
            break;
          case 2:
            mainQuestion.classList.add('hidden');
            subQuestions[0].classList.add('active');
            subQuestions[1].classList.add('active');
            break;
          case 3:
            mainQuestion.classList.add('hidden');
            subQuestions[0].classList.add('active');
            subQuestions[1].classList.add('active');
            subQuestions[2].classList.add('active');
            if (continueText) continueText.classList.add('show');
            if (arrowButton) arrowButton.style.display = 'none';
            break;
        }
      }
      
      function nextStep() {
        if (isAnimating || currentStep >= totalSteps - 1) return;
        
        isAnimating = true;
        currentStep++;
        updateDisplay();
        
        setTimeout(() => {
          isAnimating = false;
        }, 800);
      }
      
      if (arrowButton) {
        arrowButton.addEventListener('click', function() {
          nextStep();
        });
      }

      document.addEventListener('keydown', function(e) {
        if (e.key === 'ArrowDown' || e.key === ' ' || e.key === 'Enter') {
          e.preventDefault();
          nextStep();
        }
      });
    });
  ")),
  
  
  # Degree & Sex capsule control
  tags$script(HTML(sprintf("
    (function(){
      function initDeg(){
        var wrap = document.getElementById('deg-seg'); if(!wrap) return;
        var glider = document.getElementById('deg-glider');
        var btns = wrap.querySelectorAll('.seg-btn');
        function setActive(btn){
          btns.forEach(function(b){ b.classList.remove('active'); });
          btn.classList.add('active');
          glider.style.width = btn.offsetWidth + 'px';
          glider.style.transform = 'translateX(' + btn.offsetLeft + 'px)';
          if(window.Shiny) Shiny.setInputValue('deg_tab', btn.dataset.value, {priority:'event'});
        }
        var first = wrap.querySelector('.seg-btn[data-value=\"%s\"]') || btns[0];
        setTimeout(function(){ setActive(first); }, 0);
        wrap.addEventListener('click', function(e){
          var b = e.target.closest('.seg-btn'); if(!b) return; e.preventDefault(); e.stopPropagation(); setActive(b);
        }, true);
        window.addEventListener('resize', function(){
          var act = wrap.querySelector('.seg-btn.active'); if(act){ setActive(act); }
        });
      }

      function initSex(){
        var wrap = document.getElementById('sex-seg'); if(!wrap) return;
        var btns = wrap.querySelectorAll('.seg-btn');

        btns.forEach(function(b){ b.classList.add('active'); });
      
        function sync(){
          var act = Array.from(btns).filter(function(b){ return b.classList.contains('active'); });
          if(!act.length){ btns[0].classList.add('active'); act = [btns[0]]; }
          var vals = act.map(function(b){ return b.dataset.value; });
          if(window.Shiny) Shiny.setInputValue('sex_pick', vals, {priority:'event'});
        }
      
        setTimeout(sync, 0);
      
        wrap.addEventListener('click', function(e){
          var b = e.target.closest('.seg-btn'); if(!b) return;
          e.preventDefault(); e.stopPropagation();
          b.classList.toggle('active');
          sync();
        }, true);

        window.addEventListener('resize', sync);
      }
      function boot(){
        initDeg(); initSex();
      }
      if(document.readyState !== 'loading') boot();
      else document.addEventListener('DOMContentLoaded', boot);
      

    function initDeg6(){
      var wrap = document.getElementById('deg-seg-6'); if(!wrap) return;
      var glider = document.getElementById('deg-glider-6');
      var btns = wrap.querySelectorAll('.seg-btn');
      function setActive(btn){
        btns.forEach(b=>b.classList.remove('active'));
        btn.classList.add('active');
        glider.style.width = btn.offsetWidth + 'px';
        glider.style.transform = 'translateX(' + btn.offsetLeft + 'px)';
        if(window.Shiny) Shiny.setInputValue('deg_tab6', btn.dataset.value, {priority:'event'});
      }
      setTimeout(function(){ if(btns.length) setActive(btns[0]); }, 0);
      wrap.addEventListener('click', function(e){
        var b = e.target.closest('.seg-btn'); if(!b) return;
        e.preventDefault(); e.stopPropagation(); setActive(b);
      }, true);
      window.addEventListener('resize', function(){
        var act = wrap.querySelector('.seg-btn.active'); if(act){ setActive(act); }
      });
    }

    function initOccDropdown(){
      var root   = document.querySelector('.occ-dd'); if(!root) return;
      var toggle = document.getElementById('occ-toggle');
      var caret  = toggle.querySelector('.caret');
      var label  = toggle.querySelector('.label');
      var menu   = document.getElementById('occ-menu');
      var items  = menu.querySelectorAll('.pill-item');
    
      function setActive(el){
        items.forEach(i=>i.classList.remove('active'));
        el.classList.add('active');
        label.textContent = el.textContent;
        if(window.Shiny) Shiny.setInputValue('occ_pick', el.dataset.value, {priority:'event'});
      }
    
      toggle.addEventListener('click', function(e){
        e.preventDefault(); e.stopPropagation();
        menu.classList.toggle('open');
        caret.style.transform = menu.classList.contains('open') ? 'rotate(180deg)' : '';
      });
    
      items.forEach(it=>{
        it.addEventListener('click', function(){
          setActive(it);
          menu.classList.remove('open');
          caret.style.transform = '';
        });
      });
    
      document.addEventListener('click', function(e){
        if(!root.contains(e.target)){ menu.classList.remove('open'); caret.style.transform=''; }
      });
    
      setTimeout(function(){ if(items.length) setActive(items[0]); }, 0);
    }

    if (document.readyState !== 'loading') { initDeg6(); initOccDropdown(); }
    else { document.addEventListener('DOMContentLoaded', function(){ initDeg6(); initOccDropdown(); }); }
    
    
    

    })();
  ", degree_order[1]))),
  
  # map plot slider and legend
  tags$script(HTML("
    document.addEventListener('DOMContentLoaded', function() {
      const playButton = document.getElementById('play-button');
      const yearSlider = document.getElementById('map_year');
      
      if (playButton && yearSlider) {
        let isPlaying = false;
        let animationInterval;
        
        playButton.addEventListener('click', function() {
          if (!isPlaying) {
            isPlaying = true;
            playButton.textContent = '❚❚ Pause';
            playButton.style.background = 'linear-gradient(135deg, #FF6B6B, #EE5A52)';
            
            let currentYear = 2007;
            animationInterval = setInterval(function() {
              if (currentYear > 2024) {
                clearInterval(animationInterval);
                isPlaying = false;
                playButton.textContent = '▶ Play';
                playButton.style.background = 'linear-gradient(135deg, #4ECDC4, #44A08D)';
                return;
              }

              $(yearSlider).val(currentYear).trigger('change');
              currentYear++;
            }, 800);
          } else {
            clearInterval(animationInterval);
            isPlaying = false;
            playButton.textContent = '▶ Play';
            playButton.style.background = 'linear-gradient(135deg, #4ECDC4, #44A08D)';
          }
        });
      }
    });
    

    function highlightLegend(value) {
      const swatches = document.querySelectorAll('.map-legend .sw');
      swatches.forEach(sw => sw.classList.remove('highlighted'));
      
      if (value === null || isNaN(value)) return;

      if (value >= 0 && value < 10) {
        document.querySelector('.sw.c0').classList.add('highlighted');
      } else if (value >= 10 && value < 20) {
        document.querySelector('.sw.c1').classList.add('highlighted');
      } else if (value >= 20 && value < 30) {
        document.querySelector('.sw.c2').classList.add('highlighted');
      } else if (value >= 30 && value < 40) {
        document.querySelector('.sw.c3').classList.add('highlighted');
      } else if (value >= 40 && value < 50) {
        document.querySelector('.sw.c4').classList.add('highlighted');
      } else if (value >= 50) {
        document.querySelector('.sw.c5').classList.add('highlighted');
      }
    }
  ")),
  
  
  
  

  tags$script(HTML("

    function initPageInteraction(pageId, textIds, totalSteps) {
      const page = document.getElementById(pageId);
      if (!page) return;
      
      const texts = textIds.map(id => document.getElementById(id));
      const arrowButton = document.getElementById(pageId + '-arrow-button');
      const continueText = page.querySelector('.continue-text');
      
      let currentStep = 0;
      let isAnimating = false;

      updateDisplay();
      
      function updateDisplay() {
        texts.forEach(text => text.classList.remove('active'));
        if (continueText) continueText.classList.remove('show');

        for (let i = 0; i < texts.length; i++) {
          if (i < currentStep) {
            texts[i].classList.add('active');
          }
        }

        if (currentStep >= totalSteps) {
          if (continueText) continueText.classList.add('show');
          if (arrowButton) arrowButton.style.display = 'none';
        }
      }
      
      function nextStep() {
        if (isAnimating || currentStep >= totalSteps) return;
        
        isAnimating = true;
        currentStep++;
        updateDisplay();
        
        setTimeout(() => {
          isAnimating = false;
        }, 800);
      }

      if (arrowButton) {
        arrowButton.addEventListener('click', function() {
          nextStep();
        });
      }

      document.addEventListener('keydown', function(e) {
        if (!page.classList.contains('active')) return;
        
        if (e.key === 'ArrowDown' || e.key === ' ' || e.key === 'Enter') {
          e.preventDefault();
          nextStep();
        }
      });
    }

    document.addEventListener('DOMContentLoaded', function() {

      initPageInteraction('page-3', ['page3-text-1', 'page3-text-2', 'page3-text-3'], 3);
 
      initPageInteraction('page-5', ['page5-text-1', 'page5-text-2'], 2);
    });
  ")),
  
  
  
  # -----------page 6------------
  tags$script(HTML("

    document.addEventListener('DOMContentLoaded', function() {
      const dataSourceBtn = document.getElementById('data-source-btn');
      const dataSourceModal = document.getElementById('data-source-modal');
      const closeModal = document.getElementById('close-modal');
      
      if (dataSourceBtn && dataSourceModal) {

        dataSourceBtn.addEventListener('click', function() {
          dataSourceModal.classList.add('modal-open');
          document.body.style.overflow = 'hidden';
        });

        closeModal.addEventListener('click', function() {
          dataSourceModal.classList.remove('modal-open');
          document.body.style.overflow = 'auto';
        });

        dataSourceModal.addEventListener('click', function(e) {
          if (e.target === dataSourceModal) {
            dataSourceModal.classList.remove('modal-open');
            document.body.style.overflow = 'auto';
          }
        });

        document.addEventListener('keydown', function(e) {
          if (e.key === 'Escape' && dataSourceModal.classList.contains('modal-open')) {
            dataSourceModal.classList.remove('modal-open');
            document.body.style.overflow = 'auto';
          }
        });
      }
    });
  ")),
  
  # ---- BODY ----
  tags$div(
    id = "snap-container",
    
    # ------------------------------title page---------------------------
    tags$section(
      class = "snap-section hero",
      style = sprintf("background-image:url('%s'); background-size:cover; background-position:center; background-repeat:no-repeat;", BG_SRC),
      tags$div(class="hero-content",
               tags$div(class="hero-title", HTML("Income and Occupational Inequality<br>Across Education, Gender and Race")),
               tags$button(
                 class = "hero-cta", "Get Started",
                 onclick = "document.querySelector('#page-1-5').scrollIntoView({behavior:'smooth'});"
               )
      )
    ),
    
    # --------------------------Page 1.5----------------------------
    tags$section(
      id = "page-1-5", 
      class = "snap-section question-page",
      tags$div(
        class = "question-container",
        tags$div(
          id = "main-question",
          class = "main-question",
          "Do you know… where and why there is inequality in who holds which jobs and who earns how much?"
        ),
        
        tags$div(
          class = "sub-questions",
          tags$div(
            id = "sub-question-1",
            class = "sub-question",
            HTML("How do median income distributions differ<br>between men and women across occupations at the same education level?")
          ),
          tags$div(
            id = "sub-question-2", 
            class = "sub-question",
            "What is the percentage of female in top management positions in different countries?"
          ),
          tags$div(
            id = "sub-question-3",
            class = "sub-question", 
            "What is the composition of different racial groups in specific occupations?"
          )
        ),
        tags$div(
          id = "arrow-button",
          class = "arrow-button",
          tags$div(class = "arrow-text", "Continue"),
          tags$div(class = "arrow-icon")
        ),
        tags$div(
          class = "continue-text",
          "Scroll down to continue exploring"
        )
      )
    ),
    
    # -----------------------------------Page 2------------------------------
    tags$section(
      id = "page-2", class = "snap-section",
      tags$div(
        class = "section-fit",
        tags$div(
          class = "row-vh",
          
          # left side
          tags$div(
            class = "left",
            tags$div(
              class = "chart",
              tags$div(
                class = "side-card side-card--flush",
                style  = "margin-left:4vh; margin-top:8vh; height:72vh; width:90%; min-height:0;",
                plotlyOutput("p_dist", width = "100%", height = "100%")
              )
            ),
            tags$div(
              class = "deg-tabs-wrap",
              id = "deg-tabs",
              tags$div(
                id = "deg-seg", class = "seg",
                tags$div(id = "deg-glider", class = "seg-glider"),
                tags$button(class="seg-btn", `data-value`="less_bachelor", degree_labels[["less_bachelor"]]),
                tags$button(class="seg-btn", `data-value`="bachelor",      degree_labels[["bachelor"]]),
                tags$button(class="seg-btn", `data-value`="bachelor_plus", degree_labels[["bachelor_plus"]]),
                tags$button(class="seg-btn", `data-value`="graduate",      degree_labels[["graduate"]])
              )
            )
          ),
          
          # right side 
          tags$div(
            class = "right",
            style = "display: flex; flex-direction: column; height: 100%; position: relative;",
            tags$div(
              style = "position:absolute; top: 8vh; right: 5%; text-align: right; z-index: 10;",
              tags$div(
                style = "font-size: clamp(20px, 3vw, 36px); color: #fff; margin-bottom: 4px; white-space: nowrap;",
                "Male more than female"
              ),
              tags$div(
                id = "gap-percentage-big",
                style = "font-size: clamp(20px, 3vw, 36px); font-weight: 800; color: #fff; white-space: nowrap;",
                textOutput("gap_text_big")
              )
            ),
            
            # sex filter tab
            tags$h3("Sex filter", style = "margin: 0; font-size: clamp(18px, 2vw, 24px); margin-top: 8vh;"),
            tags$div(
              class = "sex-tabs-wrap",
              style = "flex-shrink: 0; margin-top: 10px;",
              tags$div(
                id = "sex-seg", class = "seg seg--multi",
                tags$button(class="seg-btn", `data-value`="men",   "Men"),
                tags$button(class="seg-btn", `data-value`="women", "Women")
              )
            ),
            
            #bar chart
            tags$div(
              class = "side-card side-card--flush",
              style  = "width:95%; min-height: 0; flex: 1; margin: 10px 0;",
              plotlyOutput("p_md", height = "100%", width = "100%")
            ),
            tags$hr(style = "flex-shrink: 0;"),
            
            #text report
            tags$div(
              id = "page2-text",
              style = "flex-shrink: 0; overflow-y: auto; max-height: 30vh;",
              tags$div(
                class = "text-description",
                style = "font-size: clamp(14px, 1.5vw, 18px); line-height: 1.4;",
                "With the same educational level,",
                "men's income distribution is generally more to the",
                tags$span(class = "text-highlight text-large", " right,"),
                "with",
                "a longer ",
                tags$span(class = "text-highlight text-large", "right tail"),
                "and a ",
                tags$span(class = "text-highlight text-large", "higher"),
                " overall median"
              ),
              
              tags$div(
                class = "text-description",
                style = "font-size: clamp(14px, 1.5vw, 18px); line-height: 1.4;",
                "The median earnings of males are on average ",
                tags$span(class = "text-highlight text-large", "20%"),
                " higher than females in all education levels. ",
              ),
              
              tags$div(
                class = "text-description",
                style = "font-size: clamp(14px, 1.5vw, 18px); line-height: 1.4;",
                "This shows that men occupy more ",
                tags$span(class = "text-highlight text-large", "high-paying "),
                "occupations, and the",
                tags$span(class = "text-highlight text-large", "gender income gap"),
                "still exists after controlling for education."
              )
            )
          )
        )
      )
    ),
    
    # ----------------------------Page 3---------------------------
    tags$section(
      id = "page-3", 
      class = "snap-section question-page",
      tags$div(
        class = "question-container",
        tags$div(
          id = "page3-title",
          class = "main-question",
          style = "opacity: 1; transform: translateY(0); margin-bottom: 80px;",
          "From income disparity to high-paying job opportunities"
        ),

        tags$div(
          class = "sub-questions",
          style = "margin-bottom: 120px;",
          tags$div(
            id = "page3-text-1",
            class = "sub-question",
            "Men still hold more high-paying positions despite having the same educational background. Part of the disparity is related to career paths and leadership representation."
          ),
          tags$div(
            id = "page3-text-2", 
            class = "sub-question",
            "Next page, we'll move to a global perspective: What is the percentage of firms with female top managers?"
          ),
          tags$div(
            id = "page3-text-3",
            class = "sub-question", 
            "Drag the years to see how the proportion of female executives changes."
          )
        ),

        tags$div(
          id = "page-3-arrow-button",
          class = "arrow-button",
          tags$div(class = "arrow-text", "Continue"),
          tags$div(class = "arrow-icon")
        ),
        tags$div(
          class = "continue-text",
          "Scroll down to continue exploring"
        )
      )
    ),
    
    # --- ---------------------Page 4 --------------------
    tags$section(
      id = "page-4",
      class = "snap-section",
      tags$div(
        class = "section-fit",
        tags$div(
          class = "row-vh row-11", 
          

          tags$div(
            class = "left",
            tags$div(
              class = "chart",
              tags$div(
                class = "side-card side-card--flush map-card",
                style = "margin-left:5vh; margin-top:10vh; height:80vh; width:90%;",
                tags$div(
                  id = "map-wrap",
                  plotlyOutput("p_map", width = "100%", height = "100%"),
       
                  tags$div(
                    class = "map-controls",

                    sliderInput("map_year", label = FALSE, min = 2007, max = 2024, value = 2024, sep = "",
                                step = 1, width = "420px", ticks = FALSE,
                                animate = animationOptions(interval = 800, loop = FALSE, playButton = "Play", pauseButton = "Pause")
                    ),

                    tags$div(
                      class = "map-legend",
                      tags$div(
                        class = "map-legend-container",
                        tags$span("No data"),
                        tags$div(class = "nodata"),
                        tags$span("0%"),
                        tags$div(
                          class = "swatches",
                          tags$div(class="sw c0"),
                          tags$div(class="sw c1"),
                          tags$div(class="sw c2"),
                          tags$div(class="sw c3"),
                          tags$div(class="sw c4"),
                          tags$div(class="sw c5")
                        ),
                        tags$span("50%")
                      ),
                      tags$div(
                        class = "map-legend-labels",
                        tags$span("0%"),
                        tags$span("10%"),
                        tags$span("20%"),
                        tags$span("30%"),
                        tags$span("40%"),
                        tags$span("50%")
                      )
                    )
                  )
                )
              )
            ),

            tags$div(
              style = "margin: 20px 0 0 4vh; max-width: 90%;",
              tags$div(
                style = "background: rgba(102, 126, 234, 0.1); border-radius: 12px; padding: 16px; border: 1px solid rgba(102, 126, 234, 0.3);",
                tags$div(
                  style = "font-size: 14px; color: #fff; font-weight: 600; margin-bottom: 8px;",
                  "Explore Further:"
                ),
                tags$div(
                  style = "font-size: 13px; color: rgba(255,255,255,0.9); line-height: 1.5;",
                  "Hover over countries to see specific percentages. Click the play button to animate changes from 2007 to 2024."
                )
              )
            )
          ),
          
          # right side
          tags$div(
            class = "right",
            
            # title
            tags$h3("Global Female Leadership"),
            
            # finding
            tags$div(
              class = "text-description",
              "The global landscape reveals ",
              tags$span(class = "text-highlight text-large", "stark contrasts"),
              " in female leadership representation across different regions."
            ),
            
            tags$div(
              class = "text-description",
              "The proportion of women in top management positions varies widely around the world, ",
              "ranging from less than",
              tags$span(class = "text-highlight text-large", "10%"),
              " to nearly ",
              tags$span(class = "text-highlight text-large", "50%"),
            ),
            
            tags$div(
              class = "text-description",
              "The region with the highest proportion of female top managers is ",
              tags$span(class = "text-highlight text-large", "Thailand"),
              ", at ",
              tags$span(class = "text-highlight text-large", "64.8%"),
              " in ",
              tags$span(class = "text-highlight text-large", "2016."),
            ),
            
            tags$div(
              class = "text-description",
              "The proportion has been ",
              tags$span(class = "text-highlight text-large", "rising slowly"),
              " over the past decade, but it has not exceeded ",
              tags$span(class = "text-highlight text-large", "30%"),
              " in most countries."
            ),
            

            tags$div(
              style = "background: rgba(255,255,255,0.08); border-radius: 12px; padding: 20px; margin-top: 25px; border-left: 4px solid #ff6b6b;",
              tags$div(
                style = "font-size: 14px; color: rgba(255,255,255,0.7); margin-bottom: 8px;",
                "KEY INSIGHT"
              ),
              tags$div(
                style = "font-size: 25px; color: #fff; line-height: 1.5;",
                "The disparity in the number of male and female executives confirms that the median income of men at all education levels is more right-skewed and long-tailed than that of women."
              )
            )
          )
        )
      )
    ),
    
    
    
    # ----------------------Page 5-----------------------------
    tags$section(
      id = "page-5", 
      class = "snap-section question-page",
      tags$div(
        class = "question-container",
        tags$div(
          id = "page5-title",
          class = "main-question",
          style = "opacity: 1; transform: translateY(0); margin-bottom: 80px;",
          "Who holds these positions?"
        ),
        tags$div(
          class = "sub-questions",
          style = "margin-bottom: 120px;",
          tags$div(
            id = "page5-text-1",
            class = "sub-question",
            "Even with the same educational background, there are still significant disparities in the number of people entering the same occupation by ethnic group."
          ),
          tags$div(
            id = "page5-text-2",
            class = "sub-question",
            "Next page: Choose an occupation and compare the number and percentage of people from four ethnic groups."
          )
        ),
        tags$div(
          id = "page-5-arrow-button",
          class = "arrow-button",
          tags$div(class = "arrow-text", "Continue"),
          tags$div(class = "arrow-icon")
        ),
        tags$div(
          class = "continue-text",
          "Scroll down to continue exploring"
        )
      )
    ),
    
    
    # --- ----------------------------Page 6 --------------------- ---
    tags$section(
      id = "page-6",
      class = "snap-section",
      tags$div(
        class = "section-fit",
        tags$div(
          class = "row-vh row-11",
          
          # left side
          tags$div(
            class = "left",
            tags$div(
              class = "chart",
              tags$div(
                class = "side-card side-card--flush occ-card",
                style = "margin-left:4vh; margin-top:8vh; height:68vh;",
                plotlyOutput("p_occ_race", height = "100%", width = "100%")
              )
            ),
            tags$div(
              class = "deg-tabs-wrap",
              tags$div(
                id = "deg-seg-6", class = "seg",
                tags$div(id = "deg-glider-6", class = "seg-glider"),
                tags$button(class="seg-btn", `data-value`="less_bachelor", degree_labels[["less_bachelor"]]),
                tags$button(class="seg-btn", `data-value`="bachelor", degree_labels[["bachelor"]]),
                tags$button(class="seg-btn", `data-value`="bachelor_plus", degree_labels[["bachelor_plus"]]),
                tags$button(class="seg-btn", `data-value`="graduate", degree_labels[["graduate"]])
              )
            )
          ),
          
          # right side
          tags$div(
            class = "right",
            
            # title
            tags$h3("Explore Occupational Diversity"),
            
            # drop down control
            tags$div(
              class = "control-section",

              tags$div(
                class = "dropdown-container",
                tags$div(
                  class = "occ-dd",
                  tags$button(
                    id = "occ-toggle", 
                    class = "pill-toggle", 
                    type = "button",
                    tags$span(class = "label", "Select occupation"),
                    tags$span(class = "caret", HTML("&nbsp;&#9660;"))
                  ),
                  tags$div(
                    id = "occ-menu", 
                    class = "pill-menu",
                    tagList(lapply(OCC_ALL, function(o) 
                      tags$div(class = "pill-item", `data-value` = o, tools::toTitleCase(o)))
                    )
                  )
                )
              ),
              

              tags$div(class = "arrow-connector"),
              
              #bubble
              tags$div(
                class = "instruction-bubble",
                tags$div(
                  class = "text-description",
                  "← Use drop-down options select different occupations!"
                )
              )
            ),
            
            tags$hr(style = "border-color: rgba(255,255,255,0.2); margin: 25px 0;"),
            
            
            
            tags$div(
              class = "text-description",
              "With the same educational level,",
              "any occupations show a pattern of ",
              tags$span(class = "text-highlight text-large", " whites"),
              " being the majority."
            ),
            
            
            tags$div(
              class = "text-description",
              tags$span(class = "text-highlight text-large", " Asians "),
              "are overrepresented in some ",
              tags$span(class = "text-highlight text-large", " professional"),
              "and ",
              tags$span(class = "text-highlight text-large", " technical "),
              "positions, ",
              "but their overall number is small.",
              
            ),
            
            
            
            
            tags$div(
              class = "text-description",
              "Although different education levels lead to ",
              tags$span(class = "text-highlight text-large", "slightly"),
              " different distributions.",
              "But education levels don't change the fact that ",
              tags$span(class = "text-highlight text-large", "white people"),
              " hold the ",
              tags$span(class = "text-highlight text-large", "majority"),
              " of jobs."
              
            ),
            
            
          )
        )
      )
    ),
    

    #------------------------------- Page 7----------------------------------
    tags$section(
      id = "page-7", 
      class = "snap-section question-page",
      tags$div(
        class = "question-container",
        style = "justify-content: center;",
        
        # main title
        tags$div(
          class = "main-question",
          style = "opacity: 1; transform: translateY(0); margin-bottom: 60px; text-align: center;",
          "Education Alone Doesn't Ensure Equality!!!"
        ),
        
        # finding card
        tags$div(
          style = "display: grid; grid-template-columns: 1fr 1fr; gap: 30px; margin-bottom: 50px; max-width: 1000px;",
          
          # 1
          tags$div(
            class = "insight-card",
            style = "background: rgba(255,255,255,0.1); padding: 25px; border-radius: 16px; border: 1px solid rgba(255,255,255,0.2);",
            tags$div(
              style = "font-size: 20px; font-weight: 700; margin-bottom: 15px; color: #63e6fb;",
              "Gender Gap Consistent"
            ),
            tags$div(
              style = "font-size: 16px; line-height: 1.5;",
              "Even with identical education, men's income is usually higher than females."
            )
          ),
          
          # 2
          tags$div(
            class = "insight-card",
            style = "background: rgba(255,255,255,0.1); padding: 25px; border-radius: 16px; border: 1px solid rgba(255,255,255,0.2);",
            tags$div(
              style = "font-size: 20px; font-weight: 700; margin-bottom: 15px; color: #ff6b6b;",
              "Global Leadership Divide"
            ),
            tags$div(
              style = "font-size: 16px; line-height: 1.5;",
              "Women remain significantly underrepresented in top management positions worldwide, with notable variations across countries and regions."
            )
          ),
          
          # 3
          tags$div(
            class = "insight-card",
            style = "background: rgba(255,255,255,0.1); padding: 25px; border-radius: 16px; border: 1px solid rgba(255,255,255,0.2); grid-column: 1 / -1; max-width: 600px; margin: 0 auto;",
            tags$div(
              style = "font-size: 20px; font-weight: 700; margin-bottom: 15px; color: #9fd356;",
              "Occupational Segregation by Race"
            ),
            tags$div(
              style = "font-size: 16px; line-height: 1.5;",
              "Significant racial disparities exist in occupational access and representation, even when controlling for educational attainment levels."
            )
          )
        ),
        
        # conclusion
        tags$div(
          style = "text-align: center; max-width: 700px; margin: 0 auto 40px;",
          tags$div(
            style = "font-size: 18px; line-height: 1.6; margin-bottom: 25px;",
            "This analysis reveals that",
            tags$strong(style = "font-size: 20px; color: #fff;", "educational equality alone is insufficient"),
            "to address systemic disparities in income distribution, leadership representation, and occupational access."
          ),
          tags$div(
            style = "font-size: 18px; line-height: 1.6;",
            "True equity requires addressing",
            tags$strong(style = "font-size: 20px; color: #fff;", "structural barriers and systemic biases"),
            "that persist across gender and racial lines."
          )
        ),
        
        
        
        
        # data source
        tags$div(
          style = "text-align: center; margin: 30px 0;",
          tags$button(
            id = "data-source-btn",
            style = "background: transparent; border: 2px solid rgba(255,255,255,0.3); color: rgba(255,255,255,0.8); padding: 12px 24px; border-radius: 25px; cursor: pointer; font-family: 'DM Sans'; font-size: 14px; transition: all 0.3s ease;",
            "Data Sources",
            onmouseover = "this.style.background='rgba(255,255,255,0.1)'; this.style.borderColor='rgba(255,255,255,0.5)';",
            onmouseout = "this.style.background='transparent'; this.style.borderColor='rgba(255,255,255,0.3)';"
          )
        ),
        
        # back to start buttom
        tags$div(
          style = "text-align: center;",
          tags$div(
            style = "font-size: 16px; color: rgba(255,255,255,0.7); margin-bottom: 30px;",
            "Thank you for exploring this data story"
          ),
          tags$button(
            class = "hero-cta",
            style = "position: relative; bottom: auto; left: auto; transform: none; margin-top: 20px;",
            "Back to Start",
            onclick = "document.querySelector('.hero').scrollIntoView({behavior:'smooth'});"
          )
        )
      ),
      
      # data source
      tags$div(
        id = "data-source-modal",
        tags$div(
          style = "background: linear-gradient(135deg, #1a1a2e 0%, #16213e 100%); border-radius: 20px; padding: 40px; max-width: 600px; width: 90%; max-height: 80vh; overflow-y: auto; position: relative; border: 1px solid rgba(255,255,255,0.1);",
          tags$button(
            id = "close-modal",
            style = "position: absolute; top: 15px; right: 15px; background: none; border: none; color: rgba(255,255,255,0.7); font-size: 24px; cursor: pointer;",
            "×"
          ),
          tags$h2(
            style = "color: #fff; margin-bottom: 25px; font-size: 24px; font-weight: 600;",
            "Data Sources"
          ),
          tags$div(
            style = "color: rgba(255,255,255,0.9); line-height: 1.6;",
            tags$h3(
              style = "color: #63e6fb; margin: 20px 0 10px; font-size: 18px;",
              "Income and Occupation Data"
            ),
            tags$p(
              "Primary dataset containing median income, occupation, education level, gender, and race information.",
              tags$br(),
              tags$strong("Source: "), "Detailed Occupation by Education, Sex, Age, Race, and Earnings: ACS 2022",
              tags$br(),
              tags$strong("URL: "), 
              tags$a(
                href = "https://www.census.gov/data/tables/2022/demo/acs-2022.html", 
                target = "_blank",
                style = "color: #7b7bff;",
                "https://www.census.gov/data/tables/2022/demo/acs-2022.html"
              )
            ),
            
            tags$h3(
              style = "color: #ff6b6b; margin: 20px 0 10px; font-size: 18px;",
              "Global Female Management Data"
            ),
            tags$p(
              "Dataset tracking the percentage of firms with female top managers across countries and years.",
              tags$br(),
              tags$strong("Source: "), "World Bank Gender Statistics",
              tags$br(),
              tags$strong("URL: "), 
              tags$a(
                href = "https://genderdata.worldbank.org/en/home", 
                target = "_blank",
                style = "color: #7b7bff;",
                "https://genderdata.worldbank.org/en/home"
              )
            ),
            
            tags$h3(
              style = "color: #9fd356; margin: 20px 0 10px; font-size: 18px;",
              "Methodology Note"
            ),
            tags$p(
              "All data has been processed and analyzed to ensure comparability across different classification systems."
            )
          )
        )
      )
    )
    
    
  )
)

# ---------- SERVER ----------------------------------
server <- function(input, output, session){
  # import data
  AB <- tryCatch(readr::read_csv("AB_merged.csv", show_col_types = FALSE), error = function(e) NULL)
  
  AB2 <- reactive({
    req(!is.null(AB))
    df <- AB %>%
      filter(!degree %in% "total",
             !tolower(occupation) %in% "total",
             !sex %in% "total",
             !is.na(median), median > 0)
    df$degree <- factor(df$degree, levels = degree_order)
    df
  })
  
  #----------------------page 2-------------------------------------------

  output$p_dist <- renderPlotly({
    req(AB2())
    deg     <- if (!is.null(input$deg_tab))  input$deg_tab  else degree_order[1]
    sel_sex <- if (!is.null(input$sex_pick)) input$sex_pick else c("men","women")
    req(length(sel_sex) > 0)
    
    df <- AB2() %>% filter(degree == deg, sex %in% sel_sex)
    req(nrow(df) > 0)
    df$sex <- factor(df$sex, levels = c("men","women"))

    r    <- range(df$median, na.rm = TRUE)
    brks <- unique(pretty(r, n = 60))
    if (length(brks) < 2) brks <- seq(floor(r[1]), ceiling(r[2]) + 1, length.out = 41)
    
    idx       <- findInterval(df$median, brks, rightmost.closed = TRUE, all.inside = TRUE)
    bin_start <- brks[pmax(idx, 1)]
    bin_end   <- brks[pmin(idx + 1, length(brks))]
    
    binned <- df %>%
      mutate(bin_start = bin_start, bin_end = bin_end,
             xmid = (bin_start + bin_end)/2, width = (bin_end - bin_start)) %>%
      group_by(sex, bin_start, bin_end, xmid, width) %>%
      summarise(count = dplyr::n(), .groups = "drop") %>%
      mutate(sex_label = ifelse(sex == "men", "Men", "Women"),
             tooltip = paste0(
               "Sex: ", sex_label,
               "<br>Degree: ", degree_labels[[deg]],
               "<br>Median earning range: ", scales::dollar(bin_start), " – ", scales::dollar(bin_end),
               "<br>Count of occupations: ", count
             ))
    
    cols <- c(men = "rgba(61,165,245,0.60)", women = "rgba(246,114,128,0.60)")
    lines <- c(men = "rgba(61,165,245,1.0)", women = "rgba(246,114,128,1.0)")
    
    p <- plot_ly()
    for (sx in c("men","women")) {
      sub <- binned %>% filter(sex == sx)
      if (nrow(sub) == 0) next
      p <- add_bars(
        p, data = sub,
        x = ~xmid, y = ~count, width = ~width,
        name = ifelse(sx == "men", "Men", "Women"),
        marker = list(color = cols[[sx]], line = list(color = lines[[sx]], width = 1)),
        hovertext     = ~tooltip,
        hoverinfo     = "text",
        hovertemplate = "%{hovertext}<extra></extra>"
      )
    }
    
    p <- layout(
      p,
      title = list(
        text = sprintf("<b>Median earnings distribution — %s</b>", degree_labels[[deg]]),
        x = 0.5, xanchor = "right",
        y = 0.98, yanchor = "top",
        font = list(
          size = 20, 
          family = "DM Sans, Arial", 
          color = "#2b2f36",
          weight = "700"
        )
      ),
      barmode = "overlay",
      margin  = list(l = 55, r = 20, t = 30, b = 50),
      xaxis   = list(title = "Median earnings per year", tickformat = "$,.0f",
                     automargin = TRUE, title_standoff = 8),
      yaxis   = list(title = "Count of occupations",
                     automargin = TRUE, title_standoff = 8),
      legend = list(orientation = "h", x = 0, y = -0.18, xanchor = "left", yanchor = "top"),
      paper_bgcolor = "rgba(0,0,0,0)", plot_bgcolor  = "rgba(0,0,0,0)"
    )
    
    p <- config(p, displayModeBar = FALSE, responsive = TRUE)
    
    # hover hightlight
    htmlwidgets::onRender(p, "
    function(el, x){
      var gd = document.getElementById(el.id);
      var base = 0.95, dim = 0.15, hi = 0.95;

      gd.on('plotly_hover', function(e){
        var pt = e.points[0];
        for (var i = 0; i < gd.data.length; i++){
          var n = (gd.data[i].x || []).length;
          var arr = Array(n).fill(dim);
          if (i === pt.curveNumber && n){ arr[pt.pointNumber] = hi; }
          Plotly.restyle(gd, {'marker.opacity': [arr]}, [i]);
        }
      });

      gd.on('plotly_unhover', function(){
        for (var i = 0; i < gd.data.length; i++){
          Plotly.restyle(gd, {'marker.opacity': base}, [i]);
        }
      });
    }
  ")
  })
  
  # right side bar chart
  output$p_md <- renderPlotly({
    req(AB2())
    deg     <- if (!is.null(input$deg_tab))  input$deg_tab  else degree_order[1]
    sel_sex <- if (!is.null(input$sex_pick)) input$sex_pick else c("men","women")
    req(length(sel_sex) > 0)
    
    df <- AB2() %>% filter(degree == deg, sex %in% sel_sex)
    req(nrow(df) > 0)
    
    md <- df %>% group_by(sex) %>%
      summarise(median_earning = median(median, na.rm = TRUE), .groups = "drop") %>%
      mutate(sex_label = ifelse(sex == "men", "Men", "Women"))
    
    cols <- c(men = "rgba(61,165,245,0.95)", women = "rgba(246,114,128,0.95)")
    line <- c(men = "rgba(61,165,245,1.0)",  women = "rgba(246,114,128,1.0)")
    
    ymax <- max(md$median_earning, na.rm = TRUE) * 1.2
    
    p <- plot_ly()
    for (sx in intersect(c("men","women"), sel_sex)) {
      sub <- md %>% filter(sex == sx)
      if (nrow(sub) == 0) next
      p <- add_bars(
        p, data = sub,
        x = ~sex_label, y = ~median_earning,
        name = ifelse(sx == "men", "Men", "Women"),
        marker = list(color = cols[[sx]], line = list(color = line[[sx]], width = 1.2)),
        width = 0.5,
        hovertemplate = paste0(
          "%{x}<br>",
          "Degree: ", degree_labels[[deg]], "<br>",
          "Median earning: %{y:$,.0f}<extra></extra>"
        ),
        text = ~scales::dollar(round(median_earning, -3)), 
        textposition = "outside",
        textfont = list(color = "#2b2f36", size = 10, family = "DM Sans, Arial, sans-serif")
      )
    }
    
    p <- layout(
      p,
      autosize = TRUE,
      barmode = "group", 
      bargap = 0.35,
      xaxis = list(
        title = "", 
        tickfont = list(size = 10),
        automargin = TRUE
      ),
      yaxis = list(
        title = "", 
        tickformat = "$,.0f", 
        rangemode = "tozero",
        range = c(0, ymax),
        gridcolor = "rgba(0,0,0,0.06)", 
        zerolinecolor = "rgba(0,0,0,0.12)",
        automargin = TRUE,
        tickfont = list(size = 9)
      ),
      showlegend = FALSE, 
      margin = list(
        t = 10, 
        r = 10, 
        b = 30, 
        l = 40,
        pad = 2
      ),
      paper_bgcolor = "rgba(0,0,0,0)", 
      plot_bgcolor  = "rgba(0,0,0,0)"
    )
    
    config(p, displayModeBar = FALSE, responsive = TRUE)
  })
  
  output$gap_text_big <- renderText({
    req(AB2())
    deg     <- if (!is.null(input$deg_tab))  input$deg_tab  else degree_order[1]
    sel_sex <- if (!is.null(input$sex_pick)) input$sex_pick else c("men","women")

    if (length(sel_sex) < 2) {
      return("--%")
    }
    
    df <- AB2() %>% filter(degree == deg, sex %in% sel_sex)
    req(nrow(df) > 0)
    
    md <- df %>% group_by(sex) %>%
      summarise(median_earning = median(median, na.rm = TRUE), .groups = "drop")
    
    men_median <- md %>% filter(sex == "men") %>% pull(median_earning)
    women_median <- md %>% filter(sex == "women") %>% pull(median_earning)
    
    if (length(men_median) > 0 && length(women_median) > 0 && women_median > 0) {
      gap_percent <- ((men_median - women_median) / women_median) * 100
      return(sprintf("+%.1f%%", gap_percent))
    } else {
      return("--%")
    }
  })
  
  # ---------------------------page 4-----------------------------
  mgr_raw <- readr::read_csv("share-firms-top-female-manager.csv", show_col_types = FALSE) |>
    dplyr::rename(
      country = Entity, iso3 = Code, year = Year,
      value = `Share of firms with a female top manager`
    )

  world_sf <- rnaturalearth::ne_countries(scale = "medium", returnclass = "sf") |>
    dplyr::select(iso3 = iso_a3, country_name = name_long, geometry)
  
  # if no data, return 10 years data
  
  pick_recent_within_10 <- function(df, yr, lookback = 10L){
    cutoff <- yr - lookback
    df |>
      dplyr::filter(year <= yr, year >= cutoff) |>
      dplyr::group_by(iso3, country) |>
      dplyr::slice_max(order_by = year, n = 1, with_ties = FALSE) |>
      dplyr::ungroup()
  }
  
  output$p_map <- plotly::renderPlotly({
    req(input$map_year)
    yr <- as.integer(input$map_year)

    recent <- pick_recent_within_10(mgr_raw, yr)

    map_df <- world_sf |>
      dplyr::left_join(recent, by = "iso3") |>
      dplyr::mutate(
        has_data = !is.na(value),

        tip_country = dplyr::coalesce(country, country_name),
        tip_text = dplyr::if_else(
          has_data,
          sprintf("%s<br>%d<br>%% of firms: %s",
                  tip_country, year, scales::percent(value/100, accuracy = 0.1)),
          sprintf("%s<br>%d<br>No data (last 10y)", tip_country, yr)
        )
      )
    
    with_data <- dplyr::filter(map_df, has_data)
    no_data   <- dplyr::filter(map_df, !has_data)
    
    # colour class
    scale_cols <- list(c(0.00, "#f7d6e6"),c(0.20, "#e8b3d3"),c(0.40, "#d38ec1"),c(0.60, "#b86aae"),c(0.80, "#923f97"),c(1.00, "#701d7a"))
    

    p <- plot_ly()
    
    # country have data
    if (nrow(with_data) > 0) {
      p <- p %>% add_trace(
        type = "choropleth",
        locations = with_data$iso3,
        z = with_data$value,
        zmin = 0, zmax = 50,
        text = with_data$tip_text,
        hovertemplate = "%{text}<extra></extra>",
        colorscale = scale_cols,
        marker = list(
          line = list(color = "white", width = 1)
        ),
        showscale = FALSE
      )
    }
    
    # country no data
    if (nrow(no_data) > 0) {
      p <- p %>% add_trace(
        type = "choropleth",
        locations = no_data$iso3,
        z = rep(0, nrow(no_data)),
        zmin = 0, zmax = 1,
        text = no_data$tip_text,
        hovertemplate = "%{text}<extra></extra>",
        colorscale = list(c(0, "#e9e9e9"), c(1, "#e9e9e9")),
        marker = list(
          line = list(color = "#cccccc", width = 1)
        ),
        showscale = FALSE
      )
    }
    
    p <- p %>% layout(
      title = list(
        text = sprintf("<b>Global Female Leadership — %d</b><br><span style='font-size: 14px; color: #666;'>Percentage of firms with female top managers</span>", yr),
        x = 0.05,
        xanchor = "left",
        y = 0.98,
        yanchor = "top",
        font = list(
          size = 20, 
          family = "DM Sans, Arial", 
          color = "#2b2f36",
          weight = "700"
        )
      ),
      geo = list(
        projection = list(type = "natural earth"),
        showframe = FALSE,
        showcoastlines = TRUE,
        coastlinecolor = "rgba(255,255,255,0.3)",
        showland = TRUE,
        landcolor = "#f8f9fa",
        showocean = TRUE,
        oceancolor = "#e9ecef",
        bgcolor = "rgba(0,0,0,0)",
        lakecolor = "#e9ecef"
      ),
      margin = list(l = 0, r = 0, t = 80, b = 0),
      paper_bgcolor = "rgba(0,0,0,0)",
      plot_bgcolor = "rgba(0,0,0,0)"
    )
    
    # hovering hightling
    p <- htmlwidgets::onRender(p, "
    function(el, x) {
      var gd = document.getElementById(el.id);
      
      gd.on('plotly_hover', function(data) {
        if (data.points && data.points[0]) {
          var point = data.points[0];
          var value = point.z;
   
          if (typeof highlightLegend === 'function') {
            highlightLegend(value);
          }
        }
      });
      
      gd.on('plotly_unhover', function(data) {
        var swatches = document.querySelectorAll('.map-legend .sw');
        swatches.forEach(function(sw) {
          sw.classList.remove('highlighted');
        });
      });
    }
  ")
    
    p
  })
  
  
  
  # ---------------------------- Page 6---------------------------
  output$p_occ_race <- renderPlotly({
    req(C_fixed)
    

    deg <- if (!is.null(input$deg_tab6)) input$deg_tab6 else degree_order[1]
    occ <- if (!is.null(input$occ_pick)) input$occ_pick else OCC_ALL[1]
    
    df <- C_fixed %>%
      dplyr::filter(
        degree == deg,
        occupation == occ,
        race %in% race_order
      ) %>%
      dplyr::mutate(
        race_label = race_labels[as.character(race)],
        pct = race_pct_est / 100,
        
        
        # tooltip
        tooltip = paste0(
          "<b>", race_label, "</b><br>",
          "Occupation: ", tools::toTitleCase(occupation), "<br>",
          "Education: ", degree_labels[[deg]], "<br>",
          "Count: ", scales::comma(race_count_est), "<br>",
          "Percentage: ", scales::percent(pct, accuracy = 0.1), "<br>",
          "Total in category: ", scales::comma(denom)
        )
      )
    
    # bar chart colour 
    cols <- c(
      Asian    = "#4ECDC4", 
      Black    = "#FF6B6B", 
      Hispanic = "#FFD166",
      White    = "#118AB2" 
    )
    

    ymax <- max(df$race_count_est, na.rm = TRUE) * 1.2

    p <- plot_ly(
      data = df,
      x = ~race_label, 
      y = ~race_count_est, 
      type = "bar",
      color = ~race_label, 
      colors = cols,
      text = ~scales::percent(pct, accuracy = 0.1),
      textposition = "outside",
      textfont = list(
        family = "DM Sans, Arial",
        size = 13,
        color = "#2b2f36"
      ),
      hovertext = ~tooltip, 
      hoverinfo = "text",
      marker = list(
        line = list(
          color = "rgba(255,255,255,0.8)", 
          width = 2
        ),
        opacity = 0.9
      ),
      
      
      # hovering 
      hoverlabel = list(
        bgcolor = "white",
        bordercolor = "transparent",
        font = list(
          family = "DM Sans, Arial",
          size = 13,
          color = "#2b2f36"
        )
      )
    )
    
    # title
    title_txt <- paste0(
      "<b>Racial Composition: ", tools::toTitleCase(occ), "</b><br>",
      "<span style='font-size: 14px; color: #666;'>", degree_labels[[deg]], " Degree Holders</span>"
    )
    
    p <- layout(
      p,
      title = list(
        text = title_txt,
        x = 0.05, 
        xanchor = "left",
        y = 0.95,
        yanchor = "top",
        font = list(
          size = 22, 
          family = "DM Sans, Arial", 
          color = "#2b2f36",
          weight = "700"
        )
      ),
      xaxis = list(
        title = "",
        tickfont = list(
          size = 13, 
          color = "#2b2f36",
          family = "DM Sans, Arial"
        ),
        gridcolor = "rgba(0,0,0,0.05)",
        showgrid = TRUE
      ),
      yaxis = list(
        title = list(
          text = "Number of Workers",
          font = list(
            size = 14,
            family = "DM Sans, Arial",
            color = "#2b2f36"
          )
        ),
        range = c(0, ymax),
        tickfont = list(
          size = 12, 
          color = "#2b2f36",
          family = "DM Sans, Arial"
        ),
        gridcolor = "rgba(0,0,0,0.08)", 
        zerolinecolor = "rgba(0,0,0,0.15)",
        showgrid = TRUE,
        zeroline = TRUE
      ),
      showlegend = FALSE,
      margin = list(t = 80, r = 30, b = 60, l = 70),
      paper_bgcolor = "rgba(0,0,0,0)", 
      plot_bgcolor = "rgba(0,0,0,0)",

      annotations = list(
        list(
          x = 0.02,
          y = 0.98,
          xref = "paper",
          yref = "paper",
          text = paste("Total:", scales::comma(sum(df$race_count_est))),
          showarrow = FALSE,
          font = list(
            size = 12,
            color = "#666",
            family = "DM Sans, Arial"
          ),
          bgcolor = "rgba(255,255,255,0.8)",
          bordercolor = "rgba(0,0,0,0.1)",
          borderwidth = 1,
          borderpad = 4,
          xanchor = "left",
          yanchor = "top"
        )
      )
    )
    
    p <- p %>% animation_opts(
      frame = 500,
      transition = 300,
      redraw = FALSE
    )
    
    config(p, displayModeBar = TRUE, responsive = TRUE)
  })
  
}



#-------------------------------------------------------
shinyApp(ui, server)