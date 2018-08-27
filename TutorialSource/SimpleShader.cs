using Microsoft.Xna.Framework;
using Microsoft.Xna.Framework.Audio;
using Microsoft.Xna.Framework.Graphics;
using Microsoft.Xna.Framework.Input;

namespace MyAwesomeGame
{
	/// <summary>
	/// This is the main type for your game.
	/// </summary>
	public class Game1 : Game
	{
		GraphicsDeviceManager	graphics;
		Texture2D				boxman;
		Vector3					boxmanPos = new Vector3(0,0,0);

		VertexBuffer			spriteVertexBuffer;
		Effect					shader;

		Matrix					World;
		Matrix					View;
		Matrix					Projection;

		int screenWidth = 800;
		int screenHeight = 600;

		public Game1()
		{
			graphics = new GraphicsDeviceManager(this);
			graphics.PreferredBackBufferWidth = screenWidth;
			graphics.PreferredBackBufferHeight = screenHeight;

			Content.RootDirectory = "Content";
		}

		/// <summary>
		/// Allows the game to perform any initialization it needs to before starting to run.
		/// This is where it can query for any required services and load any non-graphic
		/// related content.  Calling base.Initialize will enumerate through any components
		/// and initialize them as well.
		/// </summary>
		protected override void Initialize()
		{
			// TODO: Add your initialization logic here
			Matrix.CreateOrthographic(screenWidth, screenHeight, 1000.0f, -1000.0f, out Projection);
			View = Matrix.CreateLookAt( new Vector3(0,0,10),Vector3.Zero, Vector3.Up);

			float width = 0.5f;
			float height = 0.5f;
			float repetitions = 1f;

			var spriteVertices = new VertexPositionNormalTexture[6];

			spriteVertices[0] = new VertexPositionNormalTexture( new Vector3(-width,height,0f),	Vector3.Forward, new Vector2(0,0));
			spriteVertices[1] = new VertexPositionNormalTexture( new Vector3(-width,-height,0f),	Vector3.Forward, new Vector2(0,repetitions));
			spriteVertices[2] = new VertexPositionNormalTexture( new Vector3(width,-height,0f),	Vector3.Forward, new Vector2(repetitions,repetitions));
			spriteVertices[3] = new VertexPositionNormalTexture( new Vector3(width,-height,0f),	Vector3.Forward, new Vector2(repetitions,repetitions));
			spriteVertices[4] = new VertexPositionNormalTexture( new Vector3(width,height,0f),	Vector3.Forward, new Vector2(repetitions,0));
			spriteVertices[5] = new VertexPositionNormalTexture( new Vector3(-width,height,0f),	Vector3.Forward, new Vector2(0,0));

			spriteVertexBuffer = new VertexBuffer(graphics.GraphicsDevice,typeof(VertexPositionNormalTexture),6,BufferUsage.WriteOnly);
			spriteVertexBuffer.Name = "Sprite Vertex Buffer";
			spriteVertexBuffer.SetData<VertexPositionNormalTexture>(spriteVertices);

			GraphicsDevice.RasterizerState = RasterizerState.CullClockwise;
			
			base.Initialize();
		}

		/// <summary>
		/// LoadContent will be called once per game and is the place to load
		/// all of your content.
		/// </summary>
		protected override void LoadContent()
		{
			// Create a new SpriteBatch, which can be used to draw textures.
			boxman = Content.Load<Texture2D>("boxman");
			shader = Content.Load<Effect>("shader");
		}

		/// <summary>
		/// UnloadContent will be called once per game and is the place to unload
		/// game-specific content.
		/// </summary>
		protected override void UnloadContent()
		{
			boxman.Dispose();
		}

		/// <summary>
		/// Allows the game to run logic such as updating the world,
		/// checking for collisions, gathering input, and playing audio.
		/// </summary>
		/// <param name="gameTime">Provides a snapshot of timing values.</param>
		protected override void Update(GameTime gameTime)
		{
			float dt = (float)gameTime.ElapsedGameTime.TotalSeconds;
			

			base.Update(gameTime);
		}

		/// <summary>
		/// This is called when the game should draw itself.
		/// </summary>
		/// <param name="gameTime">Provides a snapshot of timing values.</param>
		protected override void Draw(GameTime gameTime)
		{	
			GraphicsDevice.Clear(Color.CornflowerBlue);
			World = Matrix.Identity;
			World *= Matrix.CreateScale(32);
			World *= Matrix.CreateTranslation(boxmanPos);
			shader.Parameters["World"].SetValue(World);
			shader.Parameters["View"].SetValue(View);
			shader.Parameters["Projection"].SetValue(Projection);
			shader.Parameters["SpriteSheet"].SetValue(boxman);

			GraphicsDevice.SetVertexBuffer(spriteVertexBuffer);

			foreach(EffectPass pass in shader.CurrentTechnique.Passes)
			{
				pass.Apply();
				GraphicsDevice.DrawPrimitives(PrimitiveType.TriangleList,0,4);
			}

			base.Draw(gameTime);
		}
	}
}
