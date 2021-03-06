package br.eng.mosaic.pigeon.web.entities 
{
	import br.eng.mosaic.pigeon.web.world.MyWorld;
	import br.eng.mosaic.pigeon.web.world.TelaInicial;
	
	import net.flashpunk.Entity;
	import net.flashpunk.Graphic;
	import net.flashpunk.Mask;
	import net.flashpunk.graphics.Image;
	import net.flashpunk.graphics.Spritemap;
	import net.flashpunk.masks.Hitbox;
	
	public class Enemy extends Entity
	{
		[Embed(source = 'br/eng/mosaic/pigeon/web/assets/inimigo_sprite_dir.png')] 
		private static const INIMIGO_DIR:Class;
		
		[Embed(source = 'br/eng/mosaic/pigeon/web/assets/inimigo_sprite_esq.png')] 
		private static const INIMIGO_ESQ:Class;
		
		public var sprEnemyDir:Spritemap;
		public var sprEnemyEsq:Spritemap;
		public var sprActive:Spritemap;
		
		public function Enemy(x:Number=0, y:Number=0, graphic:Graphic=null, mask:Mask=null)
		{
			super(x, y, graphic, mask);
			
			sprEnemyDir = new Spritemap(INIMIGO_DIR, 100, 110);
			sprEnemyDir.add("vooInimigo", [1, 0, 2, 0], 10, true); 
			
			sprEnemyEsq = new Spritemap(INIMIGO_ESQ, 100, 110);
			sprEnemyEsq.add("vooInimigo", [1, 2, 1, 0], 10, true); 
			
			if (MyWorld.userX >= this.x){
				sprActive = sprEnemyDir;
			} else {
				sprActive = sprEnemyEsq;
			}
			
			this.graphic = sprActive;

			//O tamanho acertável é 10x10 menor, e o centro fica 5x5 desclocado, para 
			//o hitbox continuar central
			setHitbox(90, 90, 5, 5);
			
			type = "enemy"; //usado para tratar a colisÃ£o
		}
		
		public function die():void{
			
			//O pombo vira uma nuvem explodida
			var cloud:Cloud = new Cloud();
			cloud.x = x;
			cloud.y = y;
			world.add(cloud);
			
			//e as penas voam. cada uma aparece em uma quina do pombo
			var pena:Pena = new Pena(Pena.ENEMY, x - 10, y);
			world.add(pena);
			pena = new Pena(Pena.ENEMY, x +(this.width), y - 10);
			world.add(pena);
			pena = new Pena(Pena.ENEMY, x, y + (this.height/2));
			world.add(pena);
			pena = new Pena(Pena.ENEMY, x +(this.width/2), y + (this.height/2) + 20);
			world.add(pena);
			
			world.remove(this);
		}
		
		
		override public function update():void{
			super.update();
			
			//Vira o inimigo para o pombo, sempre
			if (MyWorld.userX >= this.x){
				sprActive = sprEnemyDir;
			} else {
				sprActive = sprEnemyEsq;
			}
			this.graphic = sprActive;
			
			//Faz a animação do vôo
			sprActive.play("vooInimigo");
			
			//Se colidiu com o tiro do usuário, morre
			if (collide("shot", x, y)){
				die();
			}
			
			if (!collide("player", x, y)) {
				//Esse fator velocidade vai dar a dificuldade do jogo
				var fatorVelocidade:int = (1 + TelaInicial.pontuacao*2/3);
				
				var userX:int = MyWorld.userX;
				var userY:int = MyWorld.userY;
				
				//Anda 2 pixels para perto do pombo, em cada eixo
				if (userX != x) {
					if (userX > x) {
						x += fatorVelocidade;
					} else {
						x -= fatorVelocidade;
					}
				}
				if (userY != y) {
					if (userY > y) {
						y += fatorVelocidade;
					} else {
						y -= fatorVelocidade;
					}
				}
			}
		}
	}
}