const SUPABASE_URL = 'https://ultxuegihbcdzccftcye.supabase.co';
const SUPABASE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVsdHh1ZWdpaGJjZHpjY2Z0Y3llIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzc3NjMzNDksImV4cCI6MjA5MzMzOTM0OX0.eTLwLsQSuTLgGSI8MMNNKabubxGuzqkNVzsSTDx0-eM';

// Inicializar el cliente con validación
if (!window.supabase) {
  console.error("Supabase library not found! Check your script tags and network connection.");
}

const supabaseClient = window.supabase ? window.supabase.createClient(SUPABASE_URL, SUPABASE_KEY) : null;
if (!supabaseClient) {
  console.error("Failed to initialize Supabase client.");
}

window.SupabaseCtrl = {
  // --------------------------------------------------------
  // AUTENTICACIÓN
  // --------------------------------------------------------
  login: async (email, password) => {
    if (!supabaseClient) return false;
    const { data, error } = await supabaseClient.auth.signInWithPassword({ email, password });
    if (error) throw error;
    return true;
  },
  
  logout: async () => {
    if (supabaseClient) await supabaseClient.auth.signOut();
  },

  // --------------------------------------------------------
  // PERFIL Y HABILIDADES
  // --------------------------------------------------------
  getPerfil: async () => {
    if (!supabaseClient) return { skills: [] };
    try {
      const { data: perfilData, error: errP } = await supabaseClient.from('perfil').select('*').single();
      const { data: skillsData, error: errS } = await supabaseClient.from('habilidades').select('*').order('orden', { ascending: true });
      return { ...(perfilData || {}), skills: skillsData || [] };
    } catch (e) {
      console.warn("Error cargando perfil desde Supabase:", e);
      return { skills: [] };
    }
  },

  // --------------------------------------------------------
  // CURSOS, SEMANAS Y ARCHIVOS
  // --------------------------------------------------------
  getCursos: async () => {
    if (!supabaseClient) return [];
    try {
      const { data, error } = await supabaseClient
        .from('cursos')
        .select(`
          id, codigo, nombre, descripcion, icono, orden,
          semanas (
            id, numero, titulo,
            archivos (
              id, nombre, descripcion, ruta, tipo
            )
          )
        `)
        .eq('activo', true)
        .order('orden', { ascending: true });
        
      if (error) throw error;
      return data || [];
    } catch (e) {
      console.warn("Error cargando la malla de cursos:", e);
      return [];
    }
  },

  getCurso: async (cursoId) => {
    if (!supabaseClient) return null;
    try {
      const { data, error } = await supabaseClient
        .from('cursos')
        .select(`
          id, codigo, nombre, descripcion, icono,
          semanas (
            id, numero, titulo,
            archivos (
              id, nombre, descripcion, ruta, tipo
            )
          )
        `)
        .eq('id', cursoId)
        .single();
        
      if (error) throw error;
      return data;
    } catch (e) {
      console.warn("Error cargando curso específico:", e);
      return null;
    }
  },

  // --------------------------------------------------------
  // FUNCIONES DE ADMINISTRADOR (CRUD)
  // --------------------------------------------------------
  updatePerfil: async (datos) => {
    if (!supabaseClient) return false;
    const { data, error } = await supabaseClient.from('perfil').update(datos).eq('id', 1);
    if (error) throw error;
    return true;
  },

  createCurso: async (datos) => {
    if (!supabaseClient) return false;
    const { data, error } = await supabaseClient.from('cursos').insert([datos]);
    if (error) throw error;
    return true;
  },

  deleteCurso: async (id) => {
    if (!supabaseClient) return false;
    const { error } = await supabaseClient.from('cursos').delete().eq('id', id);
    if (error) throw error;
    return true;
  },

  createArchivo: async (cursoId, semanaNum, datosArchivo) => {
    if (!supabaseClient) return false;
    const { data: semana, error: errSemana } = await supabaseClient
      .from('semanas').select('id').eq('curso_id', cursoId).eq('numero', semanaNum).single();
    if (errSemana) throw errSemana;
    
    const { error: errInsert } = await supabaseClient
      .from('archivos').insert([{
        semana_id: semana.id,
        nombre: datosArchivo.nombre,
        ruta: datosArchivo.ruta,
        tipo: 'archivo'
      }]);
    if (errInsert) throw errInsert;
    return true;
  },

  uploadStorageFile: async (file) => {
    if (!supabaseClient) return null;
    const cleanName = file.name.replace(/[^a-zA-Z0-9.]/g, '_');
    const fileName = `${Date.now()}_${cleanName}`;
    const filePath = `materiales/${fileName}`;

    const { data, error } = await supabaseClient.storage
      .from('archivos_academicos')
      .upload(filePath, file, { cacheControl: '3600', upsert: false });

    if (error) throw error;
    const { data: urlData } = supabaseClient.storage.from('archivos_academicos').getPublicUrl(filePath);
    return urlData.publicUrl;
  },

  deleteArchivo: async (id) => {
    if (!supabaseClient) return false;
    const { error } = await supabaseClient.from('archivos').delete().eq('id', id);
    if (error) throw error;
    return true;
  },

  updateArchivo: async (cursoId, semanaNum, archivoId, datos) => {
    if (!supabaseClient) return false;
    const { error } = await supabaseClient.from('archivos').update(datos).eq('id', archivoId);
    if (error) throw error;
    return true;
  }
};
