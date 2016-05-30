io.stdout:setvbuf('no')
if arg[#arg] == "-debug" then require("mobdebug").start() end

local spriteManager = require("spritemanager")

-- Globales utiles
local largeurEcran
local hauteurEcran

-- Constantes
local LARGEURTILE = 64
local HAUTEURTILE = 64

-- Le donjon
local donjon = require("donjon")

local samSprite = {}
local salleFond = {}

local salleCourante = {}
salleCourante.portes = {}

local mapMurs = {}
mapMurs[1]  = {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1}
mapMurs[2]  = {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1}
mapMurs[3]  = {1,1,0,0,0,0,0,0,0,0,0,0,0,0,1,1}
mapMurs[4]  = {1,1,0,0,0,0,0,0,0,0,0,0,0,0,1,1}
mapMurs[5]  = {1,1,0,0,0,0,0,0,0,0,0,0,0,0,1,1}
mapMurs[6]  = {1,1,0,0,0,0,0,0,0,0,0,0,0,0,1,1}
mapMurs[7]  = {1,1,0,0,0,0,0,0,0,0,0,0,0,0,1,1}
mapMurs[8]  = {1,1,0,0,0,0,0,0,0,0,0,0,0,0,1,1}
mapMurs[9]  = {1,1,0,0,0,0,0,0,0,0,0,0,0,0,1,1}
mapMurs[10] = {1,1,0,0,0,0,0,0,0,0,0,0,0,0,1,1}
mapMurs[11] = {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1}
mapMurs[12] = {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1}

function CreePorte(pType, pX, pY, pLargeur, pHauteur)
  
  print("Ajoute une porte de type",pType)
  
  local newPorte = {}
  
  newPorte.x = pX
  newPorte.y = pY
  newPorte.largeur = pLargeur
  newPorte.hauteur = pHauteur
  
  return newPorte
end

function ChargeSalle(pSalle)
  
  salleCourante.portes = {}
  
  if pSalle.porteHaut == true then
    local porte = CreePorte("porteHaut",(largeurEcran/2)-LARGEURTILE,0+5,LARGEURTILE*2,HAUTEURTILE*2)
    table.insert(salleCourante.portes, porte)
  end
  if pSalle.porteDroite == true then
    local porte = CreePorte("porteDroite",largeurEcran-(LARGEURTILE*2)-5,(hauteurEcran/2)-HAUTEURTILE,LARGEURTILE*2,HAUTEURTILE*2)
    table.insert(salleCourante.portes, porte)
  end
  if pSalle.porteBas == true then
    local porte = CreePorte("porteBas",(largeurEcran/2)-LARGEURTILE,hauteurEcran-(HAUTEURTILE*2)-5,LARGEURTILE*2,HAUTEURTILE*2)
    table.insert(salleCourante.portes, porte)
  end
  if pSalle.porteGauche == true then
    local porte = CreePorte("porteGauche",0+5,(hauteurEcran/2)-HAUTEURTILE,LARGEURTILE*2,HAUTEURTILE*2)
    table.insert(salleCourante.portes, porte)
  end
  
  salleCourante.salle = pSalle
  
end

function DemarreJeu()
  
  samSprite = spriteManager.CreeSprite("p1_walk",11,0,0)
  
  samSprite.x = largeurEcran/2
  samSprite.y = hauteurEcran/2
  
  donjon.GenereDonjon()
  
  ChargeSalle(donjon.salleDepart)
  
end

function love.load()
  
  love.window.setTitle( "Redemption of Sam (c) 2015 David Mekersa from Gamecodeur.fr" )
  love.window.setMode(1024, 768, {fullscreen=false, vsync=true}) --, minwidth=1024, minheight=768})
  
  largeurEcran = love.graphics.getWidth()
  hauteurEcran = love.graphics.getHeight()
  
  salleFond = love.graphics.newImage("images/salle.png")
  
  DemarreJeu()
  
end

function love.update(dt)
  
  local ancienX = samSprite.x
  local ancienY = samSprite.y
  
  spriteManager.update(dt)
  
  if math.abs(samSprite.vx) < 1 and math.abs(samSprite.vy) < 1 then
    samSprite.frame = 1
  end
  
  if love.keyboard.isDown("d") then
    samSprite.vx = samSprite.vx + 1
    samSprite.flip = 1
  end
  if love.keyboard.isDown("q") then
    samSprite.vx = samSprite.vx - 1
    samSprite.flip = -1
  end
  if love.keyboard.isDown("z") then
    samSprite.vy = samSprite.vy - 1
  end
  if love.keyboard.isDown("s") then
    samSprite.vy = samSprite.vy + 1
  end
  
  local nColonneCollision
  local nLigneCollision
  
  nColonneCollision = math.floor((samSprite.x / LARGEURTILE) + 1)
  nLigneCollision = math.floor((((samSprite.y-6)+samSprite.h/2) / HAUTEURTILE) + 1)
  
  if mapMurs[nLigneCollision][nColonneCollision] > 0 then
    samSprite.x = ancienX
    samSprite.y = ancienY
    samSprite.vx = 0
    samSprite.vy = 0
  end
  
end

function love.draw()
  
  love.graphics.draw(salleFond,0,0)
  
  local nPorte
  for nPorte = 1,#salleCourante.portes do
    local p = salleCourante.portes[nPorte]
    love.graphics.rectangle("line",p.x,p.y,p.largeur,p.hauteur)
  end
  
  donjon.DessineMapDonjon(salleCourante.salle)
    
  spriteManager.draw()
  
  love.graphics.circle("fill",samSprite.x,((samSprite.y-6)+samSprite.h/2),5)
      
end

function love.keypressed(key)
  if key == "space" or key == " " then
    DemarreJeu()
  end
end