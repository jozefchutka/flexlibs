package sk.yoz.memory
{
    import flash.utils.Endian;
    
    import flexunit.framework.Assert;

    public class BacilTest
    {
        [Before]
        public function setUp():void
        {
        }
        
        [After]
        public function tearDown():void
        {
        }
        
        [BeforeClass]
        public static function setUpBeforeClass():void
        {
        }
        
        [AfterClass]
        public static function tearDownAfterClass():void
        {
        }
        
        [Test]
        public function emptyBacil_create_equalsExpected():void
        {
            var bacil:Bacil = new Bacil(Endian.BIG_ENDIAN);
            
            Assert.assertEquals(0, bacil.create("a"));
            Assert.assertEquals(1, bacil.create("b"));
            Assert.assertEquals(2, bacil.create("c"));
        }
        
        [Test]
        public function customBacil_read_equalsExpected():void
        {
            var bacil:Bacil = new Bacil(Endian.BIG_ENDIAN);
            var indexA:uint = bacil.create("a");
            var indexB:uint = bacil.create("b");
            var indexC:uint = bacil.create("c");
            
            Assert.assertEquals("a", bacil.read(indexA));
            Assert.assertEquals("b", bacil.read(indexB));
            Assert.assertEquals("c", bacil.read(indexC));
        }
        
        [Test]
        public function customBacil_update_equalsExpected():void
        {
            var bacil:Bacil = new Bacil(Endian.BIG_ENDIAN);
            var indexA:uint = bacil.create("a");
            var indexB:uint = bacil.create("b");
            var indexC:uint = bacil.create("c");
            
            bacil.update(indexA, "ab");
            Assert.assertEquals("ab", bacil.read(indexA));
            Assert.assertEquals("b", bacil.read(indexB));
            Assert.assertEquals("c", bacil.read(indexC));
            
            bacil.update(indexB, "bc");
            Assert.assertEquals("ab", bacil.read(indexA));
            Assert.assertEquals("bc", bacil.read(indexB));
            Assert.assertEquals("c", bacil.read(indexC));
            
            bacil.update(indexC, "cd");
            Assert.assertEquals("ab", bacil.read(indexA));
            Assert.assertEquals("bc", bacil.read(indexB));
            Assert.assertEquals("cd", bacil.read(indexC));
        }
        
        [Test]
        public function customBacil_del_equalsExpected():void
        {
            var bacil:Bacil = new Bacil(Endian.BIG_ENDIAN);
            var indexA:uint = bacil.create("a");
            var indexB:uint = bacil.create("b");
            var indexC:uint = bacil.create("c");
            
            bacil.del(indexA);
            Assert.assertEquals("b", bacil.read(indexB));
            Assert.assertEquals("c", bacil.read(indexC));
            
            bacil.del(indexB);
            Assert.assertEquals("c", bacil.read(indexC));
            
            bacil.del(indexC);
            Assert.assertEquals(0, bacil.byteArray.length);
        }
        
        [Test]
        public function customBacil_customManipulation_equalsExpected():void
        {
            var bacil:Bacil = new Bacil(Endian.BIG_ENDIAN);
            var indexA:uint = bacil.create("a");
            var indexB:uint = bacil.create(2);
            var indexC:uint = bacil.create(true);
            
            Assert.assertEquals(0, indexA);
            Assert.assertEquals(1, indexB);
            Assert.assertEquals(2, indexC);
            Assert.assertEquals("a", bacil.read(indexA));
            Assert.assertEquals(2, bacil.read(indexB));
            Assert.assertEquals(true, bacil.read(indexC));
            
            bacil.update(indexA, true);
            bacil.update(indexB, 1.1);
            bacil.update(indexC, "hello");
            
            Assert.assertEquals(true, bacil.read(indexA));
            Assert.assertEquals(1.1, bacil.read(indexB));
            Assert.assertEquals("hello", bacil.read(indexC));
            
            bacil.del(indexB);
            bacil.update(indexC, 3);
            var indexD:uint = bacil.create({a:1});
            Assert.assertEquals(3, indexD);
            Assert.assertObjectEquals({a:1}, bacil.read(indexD));
            
            bacil.del(indexD);
            bacil.del(indexC);
            bacil.del(indexA);
            Assert.assertEquals(0, bacil.byteArray.length);
        }
    }
}