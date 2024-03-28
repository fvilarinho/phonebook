package br.app.vila.phonebook.service;

import br.app.vila.phonebook.model.Phone;
import br.app.vila.phonebook.repository.PhoneRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class PhoneService {

    private final PhoneRepository phoneRepository;

    @Autowired
    public PhoneService(PhoneRepository phoneRepository) {
        this.phoneRepository = phoneRepository;
    }

    public List<Phone> findAll() {
        return phoneRepository.findAll();
    }

    public Optional<Phone> findById(Long id) {
        return phoneRepository.findById(id);
    }

    public List<Phone> findAllByName(String name) { return phoneRepository.findByNameContainingIgnoreCase(name); }

    public Phone save(Phone phone) {
        return phoneRepository.save(phone);
    }

    public void deleteById(Long id) {
        phoneRepository.deleteById(id);
    }
}
